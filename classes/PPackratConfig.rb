require 'pp'

module PPackratConfig
	#checkYourConfig is called when an error is encountered reading the configuration. 
	def self.checkYourConfig
		puts "PPackratConfig:  Please check your configuration."
		@BadConfig=TRUE
	end
	#This function is intended to be run AFTER the the configurations have been set
	#to make sure the configurations entered are sane.
	#if silent is not nil, then silent mode is activated for this function.
	def self.sanityCheck silent=nil
		@Configs.each {|config_name, config|
			puts "sanityCheck(): Warning, you have entered a blank configuration for '#{config_name}'!" if silent!=nil and config==nil
			unless config.nil?
	
				#Unless a global backup directory is set, make sure every config has it's own backup dir specified
				if @BackupDestinations.empty? 
					raise "No Global backup directory is set, and config '#{config_name}' does not have one set either!" if config['BackupDestination'].nil?
				end #of unless @BackupDestinations.empty?
			end #of unless config.nil?
		}
	end 
	class <<self
		#To be called once at the beginning of the config file
		def initialize
			@numOfConfigs||=0
			@Configs||={}
			@BadConfig||=FALSE
			@BackupDestinations||=''
			@SilentMode||=FALSE
		end

		#setBackupDestination is a way of specifying a global backup Destination.
		#Global backup destinations will be used in leu of specifying a backup destination in the individual configs by name.
		#
		#backup_destination must exist and it must be a directory.
		def setBackupDestination backup_destination
			PPackrat.checkYourconfig unless File.exist?(backup_destination) and File.directory?(backup_destination)
			@BackupDestinations = backup_destination
			return TRUE
		end
		#Running PPackratConfig.setSilent will set silent mode on.
		#Default is off.
		def setSilent
			@SilentMode=TRUE
		end
		#Is silent mode set to TRUE or FALSE?
		def silentMode?
			@SilentMode
		end

		#addName creates a new blank configuration with the name you provided.
		#The config is then populated by referencing the name, and using the set* functions below.
		def addName configName
			if @Configs.include? configName
				puts "Config names must be unique"
				PPackratConfig.checkYourConfig
			end
			@Configs.merge!({ configName=>nil }) and return TRUE unless @Configs.include?(configName)
			return FALSE
		end
		#Number of configurations currently entered
		def length
			@Configs.length
		end
		#To look at the configuration
		def [] configName
			@Configs[configName]
		end
		#Dump configuration
		def dumpConfig
			@Configs
		end
		#name is the name of the config who's file your setting.
		#
		#thingToBackup is an absolute path to the file or directory that you want backed up
		def setBackupTarget name, thingToBackup
			unless @Configs.include? name
				puts "Must addName('#{name}') first"
				PPackratConfig.checkYourConfig
			end
			@Configs[name]||={}
			@Configs[name]['BackupTarget']=thingToBackup
			unless File.exist? thingToBackup
				puts "PPackratConfig:  File or directory does not exist? '#{thingToBackup}'"
				PPackratConfig.checkYourConfig
			end
			return TRUE
		end
		#name is the name of the config your setting.
		#
		#exclusion is a file or directory that you want to exclude from the backup target.
		#exclusion must be a subdirectory of the backup target.
		def setBackupExclusions name, exclusion
			unless @Configs.include?(name) and File.exist?(exclusion)
				puts "name not yet addName'd, or exclusion file/dir does not exist"
				PPackratConfig.checkYourConfig 
			end
			if exclusion.slice(0,@Configs[name]['BackupTarget'].length)!=@Configs[name]['BackupTarget']
				puts "When using exclusions in this way, you must specify an exclusion which is a subset of the BackupTarget.\nSee Exclusions in the documentation"
				PPackratConfig.checkYourConfig
			end
			@Configs[name]['Exclusions']||=[]
			@Configs[name]['Exclusions'] << exclusion unless @Configs[name]['Exclusions'].include? exclusion
			return TRUE
		end
		#name is the name of the config your setting.
		#
		#guaranteed_num_of_backups is the guarunteed number of duplicates you want to keep across your drives.
		#guaranteed_num_of_backups must be an integer, or a string containing an integer
		#
		#<b>Note</b> that setting guaranteed_num_of_backups larger than the total number of backup drives your using
		#will issue a warning, and the maximum number of duplicates possible will be stored (one per device).
		def setDuplication name, guaranteed_num_of_backups
			unless @Configs.include?(name)
				puts "Must first addname('#{name}')"
				PPackrat.checkYourConfig
			end
			@Configs[name]['GuaranteedNumBackups']==guaranteed_num_of_backups.to_i
			return TRUE
		end
		#If setIsCritical is called with a name, and anything_but_nil as anything except nil, then
		#the backup specified by this name will be considered critical, and one copy will be kept
		#on every drive.
		def setIsCritical? name, anything_but_nil=nil
			unless @Configs.include?(name)
				puts "Must first addName('#{name}')"
				PPackrat.checkYourConfig
			end
			@Configs[name]['CriticalBackup']=TRUE
			return TRUE
		end
		#setBackupDestinationOn sets the backup destination for a specific configuration as referenced
		#by name.  There can only be one backup destination per config when specified in this method.
		#subsequent calls simply overwrite the previous entry.
		def setBackupDestinationOn name, backup_destination
			unless @Configs.include?(name) and File.exist?(backup_destination) and File.directory?(backup_destination)
				puts "Must first addName('#{name}'), and '#{backup_destination}' must first exist and be a directory."
				PPackratConfig.checkYourConfig 
			end
			@Configs[name]||={}
			@Configs[name]['BackupDestination']||=''
			@Configs[name]['BackupDestination']= backup_destination
			return TRUE
		end
	end
	initialize
end
