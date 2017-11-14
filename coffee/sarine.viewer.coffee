###!
sarine.viewer - v0.3.4 -  Wednesday, November 8th, 2017, 3:00:02 PM 
 The source code, name, and look and feel of the software are Copyright © 2015 Sarine Technologies Ltd. All Rights Reserved. You may not duplicate, copy, reuse, sell or otherwise exploit any portion of the code, content or visual design elements without express written permission from Sarine Technologies Ltd. The terms and conditions of the sarine.com website (http://sarine.com/terms-and-conditions/) apply to the access and use of this software.
###
class Viewer
  rm = ResourceManager.getInstance();
  constructor: (options) ->
    console.log("")
    @first_init_defer = $.Deferred()
    @full_init_defer = $.Deferred()
    {@src, @element,@autoPlay,@callbackPic} = options
    @id = @element[0].id;
    @element = @convertElement()
    Object.getOwnPropertyNames(Viewer.prototype).forEach((k)-> 
      if @[k].name == "Error" 
          console.error @id, k, "Must be implement" , @
    ,
      @)
    @element.data "class", @
    @element.on "play", (e)-> $(e.target).data("class").play.apply($(e.target).data("class"),[true])
    @element.on "stop", (e)-> $(e.target).data("class").stop.apply($(e.target).data("class"),[true])
    @element.on "cancel", (e)-> $(e.target).data("class").cancel().apply($(e.target).data("class"),[true])
  error = () ->
    console.error(@id,"must be implement" )
  first_init: Error
  full_init: Error
  play: Error
  stop: Error
  convertElement : Error
  cancel : ()-> rm.cancel(@)
  loadImage : (src)-> rm.loadImage.apply(@,[src])
  loadAssets : (resources, onScriptLoadEnd) ->
    # resources item should contain 2 properties: element (script/css) and src.
    if (resources isnt null and resources.length > 0)
      scripts = []
      for resource in resources
          if(resource.element == 'script')
            scripts.push(resource.src + cacheVersion)
          else
            element = document.createElement(resource.element)
            element.href = resource.src + cacheVersion
            element.rel= "stylesheet"
            element.type= "text/css"
            $(document.head).prepend(element)
      
      scriptsLoaded = 0;
      scripts.forEach((script) ->
          $.getScript(script,  () ->
              if(++scriptsLoaded == scripts.length) 
                onScriptLoadEnd();
          )
        )

    return      
  setTimeout : (delay,callback)-> rm.setTimeout.apply(@,[@delay,callback]) 
    
@Viewer = Viewer 