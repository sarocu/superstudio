require 'sqlite3'
require 'csv'
require 'rainbow'

class Simulation
    def initialize(workflow_path)
        @osw = workflow_path
    end

    def run
        begin
            unless system('which openstudio')
                raise "OpenStudio EXE not found"
            else
                system("openstudio run --workflow #{@osw}")
            end
        rescue => exception
            puts Rainbow("Could not run simulation").red
            puts Rainbow(exception.to_s).red
        end
    end

    def extract_run_results(query)
        # Query will be an object that consists of:
        # - table name in eplusout.sql
        # - variables to extract
        # - optional filter?
    end

    def save_to_csv(query_results, save_path)

    end

    def save_to_json(query_results, save_path)

    end
end