
function createFilePath(root, subdirs)
   local path = root
   for i=1, #subdirs do
      if subdirs[i] then
         path = path..'/'..subdirs[i]
      end
   end
   return path
end


function fileBrowser(rootPath, subdirs)
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
         table.insert(files, all[i])
      end
      if t == 'directory' then
         table.insert(directories, all[i])
      end
   end
   return  {root=rootPath,
            subdirs=subdirs,
            files=files,
            directories=directories}
   --print(inspect(love.filesystem.getDirectoryItems(rootPath)))
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
            
            love.graphics.print(string.gsub(browser.files[i], '.wav', ''), runningX, runningY )
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
         
         browser = fileBrowser(browser.root, browser.subdirs)
      else
         local file =  browser.files[index - #browser.directories]
         local path = createFilePath(browser.root, browser.subdirs)

         
         if stringEndsWith(file, '.wav') then
            lastClickedFile = file
            channel.main2audio:push({osc= path..'/'..file})
         end
         
      end
   end
   return browser
end
