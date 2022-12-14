
function createFilePath(root, subdirs)
   local path = root
   for i=1, #subdirs do
      if subdirs[i] then
         path = path..'/'..subdirs[i]
      end
   end
   return path
end
function TableConcat(t1,t2)
    for i=1,#t2 do
        t1[#t1+1] = t2[i]
    end
    return t1
end


function handleFileBrowserWheelMoved(browser, a,b)
   browser.scrollTop = browser.scrollTop + b
   if browser.scrollTop < 0 then browser.scrollTop = 0 end
   if browser.scrollTop > #browser.all then browser.scrollTop = #browser.all end
   browser.scrollTop = math.floor(browser.scrollTop)
end


function fileBrowser(rootPath, subdirs, allowedExtensions)
   local path = createFilePath(rootPath, subdirs)
   local all = love.filesystem.getDirectoryItems(path);
   local files={}
   local directories={}

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



function renderBrowser(browser, x, y, w, h)
   --if not browser then return end
   local runningX, runningY

   browser.x = x
   browser.y = y
   --browser.h = h
   --runningX = 20
   runningY = browser.y
   local buttonWidth = w
   local buttonHeight = 20
   local amount = h/buttonHeight
   browser.amount = amount
   
   for i=1+browser.scrollTop, math.min(#browser.all, browser.scrollTop+amount)  do
      local thing =  browser.all[i]
      --if thing then 
         if thing.type == 'directory' then
            love.graphics.setColor(red[1],red[2],red[3], 0.2)
            love.graphics.rectangle('fill', x, runningY, buttonWidth, buttonHeight)
            love.graphics.setColor(1,1,1)
            love.graphics.print(thing.path, x, runningY )
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
            
            love.graphics.print(filename, x, runningY )
         end
      --end
      runningY = runningY + buttonHeight
   end
end

function ends_with(str, ending)
   return ending == "" or str:sub(-#ending) == ending
end

function handleBrowserClick(browser,x,y)
   --if not browser.x or not browser.y then return end
   local result = false
   if x> browser.x and x < browser.x+200 and y > browser.y then
      
      local index = math.floor((y-browser.y)/20) + 1
      index = index + browser.scrollTop
      
      local thing = browser.all[index]
      if index > #browser.all then return end
      if not thing then return end
      if thing.type == 'directory' then
         if thing.path=='..' then
            table.remove(browser.subdirs)
         else
            table.insert(browser.subdirs, thing.path)
         end
         result = true
        
      elseif thing.type == 'file' then
         local path = createFilePath(browser.root, browser.subdirs)
         if thing.path then
            browser.lastClickedFile = thing.path
            if ends_with(thing.path, 'wav') or ends_with(thing.path, 'WAV') then
               channel.main2audio:push({osc= {path=thing.path, fullPath=path..'/'..thing.path}})
            end
            if ends_with(thing.path, 'lua') then
               contents, size = love.filesystem.read( path..'/'..thing.path )
               local instr = (loadstring(contents)())
               channel.main2audio:push({loadInstrument={instrument=instr, path=thing.path}})
            end
            
            
         end
      end

   end

   return result
end
