#!/usr/bin/ruby
=begin
		Copyright 2009 Jeff Welling (jeff.welling (a) gmail.com)
		This file is part of ParanoidPackrat.

    ParanoidPackrat is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    ParanoidPackrat is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with ParanoidPackrat.  If not, see <http://www.gnu.org/licenses/>.
=end

require 'pp'
load 'classes/PPackratConfig.rb'
load 'modules/PPCommon.rb'
#Load the options and config file from the command line
#FIXME How can this be done without hardcoding?  Expect it to be in /etc/?
config='/home/jeff/Documents/Projects/ParanoidPackrat/ParanoidPackrat.config.rb'
silent_mode=''

ARGV.each {|cli_arg|
	if cli_arg[/^--config=/]
		raise "--config file must exist, and be readable!" unless File.exist?(cli_arg.gsub(/^--config=/, '')) and File.readable?(cli_arg.gsub(/^--config=/, ''))
		config=cli_arg.gsub(/^--config=/, '')
		next
	elsif cli_arg[/^--silent/]
		silent_mode=TRUE
		next
	end		
}
load "#{config}"

#Don't actually run unless we are being executed from the CLI, just load.
if $0 == __FILE__ 
	PPackratConfig.sanityCheck silent_mode
end


