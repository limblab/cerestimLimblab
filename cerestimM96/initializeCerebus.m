function initializeCerebus()
    %opens connection to the cerebus via cbmex, and preps the file storage
    %by setting it to stop recording
    cbmex('open')
    %start file storeage app, or stop recording if already started
    fName='temp';
    cbmex('fileconfig',fName,'',0)
    pause(1)
end