#!/usr/bin/env ruby

module FtpModule 
    MaxLinesPerConnection = 10
    
    def self.instance
        @@instance
    end
    
    def processSizeCommand(data51)
        if File.exists?(data51)
            send_data("213 #{File.size(data51)} \n")
        else
            send_data("550 \n") # file not found
        end
    end
    
    def notifyStorCompleted
        send_data("226 \n")
    end
    
    def notifyLsCompleted
        send_data "216 \n"
    end
    
    
    def post_init
        puts "Received a new connection"
        @data_received = ""
        @line_count = 0
        @@instance=self
        @currentWorkingDirectory=Dir.pwd
        send_data "220 \n"
        
    end
    
    def receive_data data
        puts "received data: #{data}" # Debug
        command = data.split(" ").first
        
        processCommand( command,data)
    end
    
    def processCommand (command,data)
        if command== 'USER'
            send_data "230 \n"
        elsif command == 'SYST'
            send_data "200 UNIX Type: L8\n"
        elsif command== 'PWD'
            send_data "200 #{@currentWorkingDirectory}\n"
            puts "200 #{@currentWorkingDirectory}\n"
        elsif command=='cwd'
            newWorkingDirectory=data[4..-1]
            puts "newWorkingDirectory: #{newWorkingDirectory}"
            @currentWorkingDirectory= newWorkingDirectory
            send_data "200 \n"
        elsif command =='TYPE'
            send_data "200 \n"
        elsif command=='PASV'
            #227 Entering Passive Mode (a1,a2,a3,a4,p1,p2)
            #where a1.a2.a3.a4 is the IP address and p1*256+p2 is the port number.
            a1=a2=a3=a4=0
            
            #1544
            p1=6
            p2=8
            
            send_data "227 Entering Passive Mode (#{a1},#{a2},#{a3},#{a4},#{p1},#{p2}) \n"
        elsif command=='EPSV'
            send_data "202 \n"
        elsif command=='list'
            send_data "150 \n"
            DataModule.instance.sendListContent(data, @currentWorkingDirectory)
        elsif command == 'SIZE'
            processSizeCommand(data[5..-1])
        elsif command=='stor'
            send_data "150 \n"
            DataModule.instance.startStor(data[5..-1])
        elsif command=='SITE'
            send_data "502 \n"
        elsif command=='DELE'
            fileName=data[5..-1]
            File.delete(fileName.strip)
            send_data "250 \n"
        end
        
        
    end
end


