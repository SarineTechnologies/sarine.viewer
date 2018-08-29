###!
sarine.viewer - v0.3.6 -  Wednesday, May 9th, 2018, 5:42:44 PM 
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
  loadAssets : (resources, onScriptLoadEnd, version) ->
    # resources item should contain 2 properties: element (script/css) and src.
    if (resources isnt null and resources.length > 0)
      scripts = []
      resourceVersion = version || cacheAssetsVersion || cacheVersion
      if resourceVersion.indexOf("?") < 0
        resourceVersion = "?" + resourceVersion
      for resource in resources
          if(resource.element == 'script')
            scripts.push(resource.src + resourceVersion)
          else
            element = document.createElement(resource.element)
            element.href = resource.src + resourceVersion
            element.rel= "stylesheet"
            element.type= "text/css"
            $(document.head).prepend(element)
      
      scriptsLoaded = 0;
      _t = @
      scripts.forEach((script) ->
          _t.loadScriptAndCache(script, {}, () ->
              if(++scriptsLoaded == scripts.length) 
                onScriptLoadEnd();
          )
        )

    return      
  setTimeout : (delay,callback)-> rm.setTimeout.apply(@,[@delay,callback]) 

  loadScriptAndCache: ( url, options, success )->
    options = $.extend( options || {}, {
      dataType: "script",
      cache: true, # cache enabled
      url: url,
      success: success
    })  
    return jQuery.ajax(options);

  loadNoStone: () ->
    defer = defer || $.Deferred()
    img = new Image()
    _noStoneImage = "data:image/png;base64,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"
    rm.loadImage.apply(@,[_noStoneImage])
    return

@Viewer = Viewer 