#!/usr/bin/env ruby

module DataModule 
    MaxLinesPerConnection = 10
    
    def unbind
        @file&.close
        
        FtpModule.instance.notifyStorCompleted
    end
    
    def startStor(data51)
        @file=File.open(data51.strip, 'wb')
    end
    
    def sendListContent(data, currentWorkingDirectory)
        puts "currentWorkingDirectory: #{currentWorkingDirectory}, lenght: #{currentWorkingDirectory.length}"
        currentWorkingDirectory.strip!
        puts "currentWorkingDirectory: #{currentWorkingDirectory}, lenght: #{currentWorkingDirectory.length}"
        extraParameter=data.split(" ")[1]
        puts "extraParameter: #{extraParameter}"
        command="ls #{extraParameter} #{currentWorkingDirectory}"
        puts "command: #{command}"
        #command: ls -la /
        
        output=`#{command}`
        send_data("#{output}\n")
        puts "sent #{output}"
        FtpModule.instance.notifyLsCompleted
    end
    
    def self.instance
        @@instance
    end
    
    def post_init
        puts "Received a new connection"
        @data_received = ""
        @line_count = 0
        @currentWorkingDirectory=Dir.pwd
        @@instance=self
        send_data "220 \n"
        
    end
    
    def receive_data data
        puts "received data: #{data}" # Debug
        #command = data.split(" ").first
        
        #processCommand( command,data)
        
        @file.syswrite(data)
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
        end
        
    end
end


