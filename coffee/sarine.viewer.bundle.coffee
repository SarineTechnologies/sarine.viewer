###!
sarine.viewer - v0.0.7 -  Wednesday, March 25th, 2015, 3:18:11 PM 
 The source code, name, and look and feel of the software are Copyright © 2015 Sarine Technologies Ltd. All Rights Reserved. You may not duplicate, copy, reuse, sell or otherwise exploit any portion of the code, content or visual design elements without express written permission from Sarine Technologies Ltd. The terms and conditions of the sarine.com website (http://sarine.com/terms-and-conditions/) apply to the access and use of this software.
###

class Viewer
  rm = ResourceManager.getInstance();
  constructor: (options) ->
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
  setTimeout : (delay,callback)-> rm.setTimeout.apply(@,[@delay,callback])
    
@Viewer = Viewer 

class ResourceManager
	_instance = undefined
	_timeoutManager = undefined
	_imageManger = undefined
	constructor: ->
		console.log 'new singleton122211'
		_timeoutManager = new TimeoutManager()
		_imageManger = new ImageManger()


	@getInstance: ->
		if _instance is undefined
			_instance = new @()
		_instance

	class ImageManger

		constructor: () ->
			
		imageObj : {}
		loadImage : (src,viewer) ->
			_t = @
			if @imageObj[viewer.id] == undefined
				@imageObj[viewer.id] = {				
					capacity : viewer.downloadLimit || 2,
					bag:[],
					threshhold:[]
				}
			defer = $.Deferred()
			img = new Image()
			img.crossOrigin = "Anonymous"
			img.onload = (e) ->
				index = $.inArray(_t.imageObj[viewer.id].threshhold.filter((v)=> return v.src == e.target.src )[0],_t.imageObj[viewer.id].threshhold)
				obj = _t.imageObj[viewer.id].threshhold[index]
				popped = _t.imageObj[viewer.id].bag.shift()
				if popped
					popped.img.src = popped.src
					_t.imageObj[viewer.id].threshhold.push(popped)
				_t.imageObj[viewer.id].threshhold.splice index , 1
				obj.defer.resolve(e.target)
				
			if @imageObj[viewer.id].threshhold.length < @imageObj[viewer.id].capacity
				@imageObj[viewer.id].threshhold.push { defer:defer, src:src , img:img}
				img.src = src
			else
				@imageObj[viewer.id].bag.push  { defer:defer, src:src , img:img}
				
						
			
				
			# if the copacity is reach the bind to the defer.then(function) of the current downloading image
			defer

	# @ (this) is for the instance that request the loadImage			
	loadImage : (src)->  _imageManger.loadImage(src,@)

	class TimeoutManager
		constructor: () ->
			# ...
		funcArr = {}

		@add : (delay,defer,item)->
			obj = {
					defer : defer
					item : item
				}
			if(!funcArr[delay])
				setTimeout((delay)->
					temp = funcArr[delay]
					funcArr[delay] = undefined
					unique = $.unique(temp.map((v)->v.item.id))
					temp.forEach((i)->i.defer.resolve.apply(i.item))
				,delay,delay)
				funcArr[delay] = []
			if (funcArr[delay].filter((v)->v.item.id == obj.item.id)).length ==  0
				funcArr[delay].push obj


		
	
	setTimeout : (delay) ->
		defer = $.Deferred()
		TimeoutManager.add(delay,defer,@)
		defer

@ResourceManager = ResourceManager

