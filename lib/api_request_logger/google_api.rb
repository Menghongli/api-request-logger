require 'google/api_client'
require 'googleauth'
require 'yaml'

Faraday.default_adapter = :httpclient

module ApiRequestLogger
  class GoogleApi

    DATASET_ID = Rails.env

    def initialize
      @authorized = false
    end

    def config
      @config = YAML.load_file(File.join(Rails.root, 'config', 'ga_config.yml'))
    end

    def client
      @client ||= Google::APIClient.new(
        application_name:     config['application_name'],
        application_version:  config['application_version']
      )
    end

    def bigquery
      @bigquery = client.discovered_api('bigquery','v2')
    end

    def storage
      @storage = client.discovered_api('storage', 'v1')
    end

    def authorize
      scopes = ['https://www.googleapis.com/auth/devstorage.read_write', 'https://www.googleapis.com/auth/bigquery']
      client.authorization = Google::Auth.get_application_default(scopes)
      client.authorization.fetch_access_token!

      @authorized = true
      @authorized_at = Time.current
    end

    def upload_file(filename, bucket, remote_filename, mime_type= 'application/x-gzip')
      resumable_media = Google::APIClient::UploadIO.new(filename, mime_type)
      resumable_result = execute(
        :api_method => storage.objects.insert,
        :media => resumable_media,
        :parameters => {
          :uploadType => 'resumable',
          :bucket => bucket,
          :name => remote_filename
        },
        :body_object => {
          :contentType => mime_type
        }
      )

      upload = resumable_result.resumable_upload
      if upload.resumable?
        execute(upload)
      end

      upload
    end

    def insert_data(file_name, bucket, table_id, schema, format='NEWLINE_DELIMITED_JSON', write_disposition = 'WRITE_APPEND')
      job_data = {
        configuration: {
          load: {
            sourceUris: ["gs://#{bucket}/#{file_name}"],
            sourceFormat: format,
            writeDisposition: write_disposition,
            allowQuotedNewlines: true,
            schema: { fields: schema },
            destinationTable: {
              projectId: config['project_id'],
              datasetId: DATASET_ID,
              tableId: table_id
            }
          }
        }
      }

      response = execute(
        api_method: bigquery.jobs.insert,
        parameters: {
          projectId: config['project_id']
        },
        body_object: job_data
      )

      MultiJson.load( response.body )
    end

    # Streams data into BigQuery
    def stream_data(table_id, data)
      body = {
        kind: 'bigquery#tableDataInsertAllRequest',
        rows: sanitize_data(data)
      }

      response = execute(
        api_method: bigquery.tabledata.insertAll,
        parameters: {
          projectId: config['project_id'],
          datasetId: DATASET_ID,
          tableId: table_id
        },
        body_object: body
      )

      MultiJson.load( response.body )
    end

    def delete_table(table_id)
      response = execute(
        api_method: bigquery.tables.delete,
        parameters: {
          projectId: config['project_id'],
          datasetId: DATASET_ID,
          tableId: table_id
        }
      )

      MultiJson.load( response.body )
    end

    def get_table(table_id)
      response = execute(
        api_method: bigquery.tables.get,
        parameters: {
          projectId: config['project_id'],
          datasetId: DATASET_ID,
          tableId: table_id
        }
      )

      MultiJson.load( response.body )
    end

    def create_table(table_id, schema)
      table_data = {
        tableReference: {
          projectId: config['project_id'],
          datasetId: DATASET_ID,
          tableId: table_id
        },
        schema: { fields: schema }
      }

      response = execute(
        api_method: bigquery.tables.insert,
        parameters: {
          projectId: config['project_id'],
          datasetId: DATASET_ID
        },
        body_object: table_data
      )

      MultiJson.load( response.body )
    end

    # Schema updates only allow you to append fields or relax field modes (e.g., required -> optional).
    # You can't change field names or types, and you can't reorder them. –  Jeremy Condit
    def patch_table_schema(table_id, old_schema, new_schema)
      old_schema.merge!(new_schema) { |key, old, new| old }

      table_data = {
        schema: { fields: old_schema }
      }

      response = execute(
        api_method: bigquery.tables.patch,
        parameters: {
          projectId: config['project_id'],
          datasetId: DATASET_ID,
          tableId: table_id
        },
        body_object: table_data
      )

      MultiJson.load( response.body )
    end

    def get_job(job_id)
      response = execute(
        :api_method => bigquery.jobs.get,
        :parameters => {
          :projectId => config['project_id'],
          :jobId => job_id
        }
      )

      MultiJson.load( response.body )
    end

    def get_jobs_list(status)
      response = execute(
        api_method: bigquery.jobs.list,
        parameters: {
          projectId: config['project_id'],
          projection: 'minimal', # Does not include the job configuration
          stateFilter: status
        }
      )

      MultiJson.load( response.body )
    end

    def execute(options = {})
      authorize if @authorized == false || Time.current - @authorized_at > 3600
      client.execute(options)
    end

    def query(sql)
      body = {
        :kind => 'bigquery#queryRequest',
        :query => sql,
        :defaultDataset => {
          :datasetId => Rails.env,
          :projectId => config['project_id']
        }
      }

      response = execute(
        :api_method => bigquery.jobs.query,
        :parameters => {
          :projectId => config['project_id']
        },
        :body_object => body
      )

      result = MultiJson.load( response.body )

      beautify_result(result)
    end

    def beautify_result(result)
      fields = result['schema']['fields']

      result['rows'].collect do |row|
        ob = {}
        fields.each_with_index do |x, y|
          ob[x['name'].to_sym] = case x['type']
          when 'TIMESTAMP'
            DateTime.strptime(row['f'][y]['v'].to_f.to_s, '%s').in_time_zone('Sydney')
          when 'INTEGER'
            row['f'][y]['v'].to_i
          else
            row['f'][y]['v']
          end
        end
        ob
      end
    rescue
      result
    end

    def get_query_results(job_id)
      response = execute(
        :api_method => bigquery.jobs.get_query_results,
        :parameters => {
          :jobId => job_id,
          :projectId => config['project_id']
        }
      )

      result = MultiJson.load( response.body )

      beautify_result(result)
    end

    def sanitize_data(data)
      data.map do |entry|
        { json: entry }
      end
    end

  end
end
