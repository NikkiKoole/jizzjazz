
function createFilePath(root, subdirs)
   local path = root
   for i=1, #subdirs do
      if subdirs[i] then
         path = path..'/'..subdirs[i]
      end
   end
   return path
end


function fileBrowser(rootPath, subdirs, allowedExtensions, allowedToUseFolders)
   local path = createFilePath(rootPath, subdirs)
   local all = love.filesystem.getDirectoryItems(path);
   local files={}
   local directories={}

  -- local result = {root=rootPath, subdir=subdir}

   if #subdirs>0 then
      table.insert(directories, '..')
   end
   
   for i= 1, #all do
      local t = love.filesystem.getInfo(path..'/'..all[i]).type
      
      if t == 'file' then
         
         if allowedExtensions then
            for j = 1, #allowedExtensions do
               if stringEndsWith(all[i], allowedExtensions[j]) then
                  table.insert(files, all[i])
               end
            end
         else
            table.insert(files, all[i])
         end
      end
      if t == 'directory' then
         table.insert(directories, all[i])
      end
   end
   return  {root=rootPath,
            subdirs=subdirs,
            files=files,
            directories=directories,
            allowedExtensions=allowedExtensions,
            allowedToUseFolders=allowedToUseFolders}
end



function renderBrowser(browser)
   local runningX, runningY
   runningX = 20
   runningY = 200
   maxY = 700
   local buttonWidth = 200
   local buttonHeight = 20

   --love.graphics.rectangle("fill", 100,100,200,200)
   
   if browser then
      
      if #browser.directories > 0 then
         for i =1,  #browser.directories do

            love.graphics.setColor(red[1],red[2],red[3], 0.2)
            love.graphics.rectangle('fill', runningX, runningY, buttonWidth, buttonHeight)
            love.graphics.setColor(1,1,1)
            love.graphics.print(browser.directories[i], runningX, runningY )
            runningY = runningY + 20
            if runningY > maxY then
               runningX = runningX + 200
               runningY = 200
            end
         end
      end
      if #browser.files > 0 then
         for i =1,  #browser.files do
            love.graphics.setColor(.1,.1,.1)
            if (lastClickedFile == browser.files[i]) then
               love.graphics.setColor(.5,.1,.1)
            end

            local filename = browser.files[i]
            if browser.allowedExtensions then
               for j = 1, #browser.allowedExtensions do
                  filename = string.gsub(filename, '.'..browser.allowedExtensions[j], '')
               end
            end
            
            love.graphics.print(filename, runningX, runningY )
            runningY = runningY + 20
            if runningY > maxY then
               runningX = runningX + 200
               runningY = 200
            end
         end
      end
   end
end


function handleBrowserClick(browser, x,y)
   if x> 20 and y > 200 then
      local index = (math.floor((x-20)/200) * 26) + math.floor((y-200)/20) + 1
      if (index <= #browser.directories) then

         if browser.directories[index] == '..' then
            table.remove(browser.subdirs)
         else
            table.insert(browser.subdirs,  browser.directories[index])
         end

         browser = fileBrowser(browser.root, browser.subdirs,
                               browser.allowedExtensions,
                               browser.allowedToUseFolders)
      else
         local file =  browser.files[index - #browser.directories]
         local path = createFilePath(browser.root, browser.subdirs)

         
         --if stringEndsWith(file, '.wav') or stringEndsWith(file, '.WAV')   then
         if file then
            lastClickedFile = file
            channel.main2audio:push({osc= path..'/'..file})
         end
         --end
         
      end
   end
   return browser
end
