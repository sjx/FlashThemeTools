package com.qihoo.themefactory.sjx.ctrl {
	import com.qihoo.themefactory.sjx.modes.Image;
	
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.external.ExternalInterface;
	import flash.net.URLRequest;
	
	import org.sjx.data.Terminal;
	
	public class ImageManager {
		
		private var _queue: Object;
		private var _zoom: Number;
		
		public function ImageManager(z: Number) {
			_zoom = z;
			_queue = {};
		}

		/** 获取图片，如果内存中已经存在，就直接从内存中读取. */
		public function getImage(src: String, time: uint, callback: Function, data: BitmapData = null): void {
			if (!src) return;
			
			if (data && data.width != 1 && data.height != 1) {
				var img: Image = new Image(data, src, _zoom)
				_queue[src] = img
			}

			/*
			// 先不做缓存处理.
			if (_queue[src] && _queue[src] is Image) {
				callback(_queue[src], time);
			}
			else {
			*/
			var loader: Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadComplete);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, loadError);
			loader.load(new URLRequest(_cache(src)));
			_queue[src] = loader;
			// }
			
			function loadComplete(evt: Event): void {
				var img: Image = new Image(evt.target.content.bitmapData, src, _zoom);
				_queue[src] = img
				callback(_queue[src], time);
			}
			
			function loadError(evt: IOErrorEvent): void {
				var img: Image = new Image(new BitmapData(10, 10), src, _zoom)
				_queue[src] = img
				callback(_queue[src], time);
			}
			
			/** 清除图片的缓存. */
			function _clearChche(url: String): String {
				var cacheIndex: int = url.indexOf('QIHOO_D_CACHE=');
				if (cacheIndex != -1) {
					var arr: Array = url.split('QIHOO_D_CACHE='), end: int = arr[1].indexOf('&');
					if (end != -1)
						arr[1] = arr[1].substring(end + 1);
					url = arr.join('');
				}
				return url;
			}
			
			/** 图片缓存处理. */
			function _cache(url: String): String {
				url = _clearChche(url);
				url += (url.indexOf('?') != -1 ? '&QIHOO_D_CACHE=' : '?QIHOO_D_CACHE=') + (new Date().time);
				if (Terminal.proxy) {
					return ExternalInterface.call(Terminal.proxy, url);
				}
				return url;
			}
		}
	}
}