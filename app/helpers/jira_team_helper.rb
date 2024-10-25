module JiraTeamHelper
  # Assuming all_issues is an array of JIRA issues with a 'resolutiondate' field
  # sorted by resolutiondate, this method will bucket the issues into 14-day chunks
  def self.bucket_tickets_by_14_day_chunks(all_issues)
    begin
      # Initialize the map to store the buckets
      buckets = Hash.new { |hash, key| hash[key] = [] }

      # Iterate over the sorted issues and bucket them into 14-day chunks
      all_issues.each do |issue|
        resolution_date = Date.parse(issue.fields['resolutiondate'])
        # Find the end date of the 14-day window
        end_date = resolution_date + (13 - (resolution_date.yday % 14))
        # Add the issue to the corresponding bucket
        buckets[end_date] << issue
      end

      buckets
    rescue => e
      Rails.logger.error e.message
      Rails.logger.error e.backtrace.join("\n")
      raise e
    end
  end
end
