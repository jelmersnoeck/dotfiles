# This allows us to save the history for IRB so we can share data between new
# IRB sessions.

require 'irb/ext/save-history'
#History configuration
IRB.conf[:SAVE_HISTORY] = 100
IRB.conf[:HISTORY_FILE] = "#{ENV['HOME']}/.irb-save-history"
