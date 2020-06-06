
function createFilePath(root, subdirs)
   local path = root
   for i=1, #subdirs do
      if subdirs[i] then
         path = path..'/'..subdirs[i]
      end
   end
   return path
end

function handleFileBrowserWheelMoved(browser, a,b)
   --print(inspect(browser))
   --print(a,b)
   browser.scrollTop = browser.scrollTop + b
   
   -- say we want 20 elements max
   --local total = #browser.directories + #browser.files
   if browser.scrollTop > #browser.all - 20 then
      browser.scrollTop = #browser.all - 20
   end
   if browser.scrollTop < 0 then browser.scrollTop = 0 end
   
   --print(#browser.directories, #browser.files)
end

function TableConcat(t1,t2)
    for i=1,#t2 do
        t1[#t1+1] = t2[i]
    end
    return t1
end

function fileBrowser(rootPath, subdirs, allowedExtensions, allowedToUseFolders)
   local path = createFilePath(rootPath, subdirs)
   local all = love.filesystem.getDirectoryItems(path);
   local files={}
   local directories={}

  -- local result = {root=rootPath, subdir=subdir}

   if #subdirs>0 then
      table.insert(directories, {path='..', type='directory'})
   end
   
   for i= 1, #all do
      local t = love.filesystem.getInfo(path..'/'..all[i]).type
      
      if t == 'file' then
         
         if allowedExtensions then
            for j = 1, #allowedExtensions do
               if stringEndsWith(all[i], allowedExtensions[j]) then
                  table.insert(files, {path=all[i], type='file'})
               end
            end
         else
            table.insert(files, {path=all[i], type='file'})
         end
      end
      if t == 'directory' then
         table.insert(directories, {path=all[i], type='directory'})
      end
   end
   return  {root=rootPath,
            subdirs=subdirs,
            files=files,
            directories=directories,
            all = TableConcat(directories, files),
            allowedExtensions=allowedExtensions,
            allowedToUseFolders=allowedToUseFolders,
            scrollTop=0}
end



function renderBrowser(browser)
   local runningX, runningY
   --runningX = 20
   runningY = 200
   maxY = 700
   local buttonWidth = 200
   local buttonHeight = 20
   for i=1+browser.scrollTop, math.min(#browser.all, 1+browser.scrollTop+20)  do
      local thing =  browser.all[i]

      if thing.type == 'directory' then
         love.graphics.setColor(red[1],red[2],red[3], 0.2)
         love.graphics.rectangle('fill', 20, runningY, buttonWidth, buttonHeight)
         love.graphics.setColor(1,1,1)
         love.graphics.print(thing.path, 20, runningY )
      else
         local filename = thing.path
         if browser.allowedExtensions then
            for j = 1, #browser.allowedExtensions do
               filename = string.gsub(filename, '.'..browser.allowedExtensions[j], '')
            end
         end
         if (browser.lastClickedFile and  browser.lastClickedFile == thing.path) then
            love.graphics.setColor(.5,.1,.1)
         else
            love.graphics.setColor(0,0,0)
         end
         
         love.graphics.print(filename, 20, runningY )
      end
      runningY = runningY + buttonHeight
   end

end


function handleBrowserClick(browser, x,y)
   if x> 20 and y > 200 then
      local index = (math.floor((x-20)/200) * 26) + math.floor((y-200)/20) + 1
      index = index + browser.scrollTop
      local thing = browser.all[index]
      if thing.type == 'directory' then
         if thing.path=='..' then
            table.remove(browser.subdirs)
         else
            table.insert(browser.subdirs, thing.path)
         end
         
         browser = fileBrowser(browser.root, browser.subdirs,
                               browser.allowedExtensions,
                               browser.allowedToUseFolders)
      elseif thing.type == 'file' then
         local path = createFilePath(browser.root, browser.subdirs)
         if thing.path then
             browser.lastClickedFile = thing.path
             channel.main2audio:push({osc= path..'/'..thing.path})
         end
      end

   end
   return browser
end
