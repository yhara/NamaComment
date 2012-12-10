#
#  AppDelegate.rb
#  NamaComment
#
#  Created by HARA Yutaka on 2012/12/06.
#  Copyright 2012年 HARA Yutaka. All rights reserved.
#
require 'rubygems'
require 'nokogiri'

class AppDelegate
    attr_accessor :window
    attr_accessor :textField
    attr_accessor :tableView
    
    def applicationDidFinishLaunching(a_notification)
        # Insert code here to initialize your application
        @comment_data = []
        @comment_xml_path = nil
    end
    
    def numberOfRowsInTableView(aTableView)
        @comment_data ||= []
        @comment_data.length
    end
    
    def tableView(aTableView, objectValueForTableColumn: aTableColumn, row: rowIndex)
        r = rowIndex
        c = (aTableColumn.identifier == "time" ? 0 : 1)
        return @comment_data[r][c]
    end
    
    def open(sender)
        panel = NSOpenPanel.openPanel
        dir = (@comment_xml_path ? File.dirname(@comment_xml_path) : NSHomeDirectory())
        
        result = panel.runModalForDirectory(dir, file: nil, types: ["xml"])
        if(result == NSOKButton)
            loadCommentFile(panel.filename)
        end
    end
    
    def prevFile(sender)
        files = commentFiles
        newpath = files[(files.index(@comment_xml_path) - 1) % files.length]
        loadCommentFile(newpath)
    end
    
    def nextFile(sender)
        files = commentFiles
        newpath = files[(files.index(@comment_xml_path) + 1) % files.length]
        loadCommentFile(newpath)
    end

    def timerHandler(obj)
        @time += 0.1
        string = sprintf("%.1f", @time)
        textField.setStringValue(string)
    end
    
    private
    
    def loadCommentFile(path)
        @comment_xml_path = File.expand_path(path)
        textField.setStringValue(File.basename(@comment_xml_path))
        @comment_data = parseCommentXml(File.read(@comment_xml_path))
        tableView.reloadData
    end
    
    def commentFiles
        return [] unless @comment_xml_path
        return Dir.glob("#{File.dirname(@comment_xml_path)}/*.xml")
                .map{|path| File.expand_path(path)}
                .sort
    end

    def parseCommentXml(txt)
        if txt =~ /<thread .*? server_time="(.*?)"/
            start_time = Time.at($1.to_i)
        else
            txt =~ /<chat .*? date="(.*?)"/
            raise "chat not found" unless $1
            start_time = Time.at($1.to_i)
        end
        
        return txt.scan(/<chat .*$/).map{|line|
            bsp = false
            number = line[/no="(.*?)"/, 1].to_i
            date = Time.at(line[/date="(.*?)"/, 1].to_i)
            time = date - start_time
            min = time / 60
            sec = time % 60
            
            text = line[/>(.*)<\/chat>$/, 1]
            if text =~ %r{\A/press show .* (.*?) @ (.*)}
                bsp = true
                text = "＜#{$2}＞ #{$1}"
            end
            [format("%02d:%02d", min, sec),
             format("%s%s", (bsp ? "" : " "), text)]
        }
    end

end

