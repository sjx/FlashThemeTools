/*
 *   /\_/\
 *  (=+_+=)
 *   (  )。
 *
 * 原来喜欢不可以伪装，原来快乐不可以假装，原来永远和瞬间一样。
 */
package {
	import com.adobe.serialization.json.JSON;
	import com.adobe.serialization.json.JSONDecoder;
	import com.adobe.serialization.json.JSONEncoder;
	import com.qihoo.themefactory.sjx.utils.Utils;
	
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.Loader;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Rectangle;
	import flash.net.FileReference;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.system.Security;
	import flash.text.TextField;
	import flash.utils.Timer;
	
	import mx.events.Request;
	
	import org.sjx.components.BuildButton;
	import org.sjx.components.BuilderTip;
	import org.sjx.components.CheckBox;
	import org.sjx.components.Confirm;
	import org.sjx.components.Dialog;
	import org.sjx.components.Input;
	import org.sjx.components.Preview;
	import org.sjx.components.ThemeInfo;
	import org.sjx.components.UploadList;
	import org.sjx.components.ViewButton;
	import org.sjx.components.WeatherWidget;
	import org.sjx.data.Terminal;
	import org.sjx.utils.TextFormats;
	
	[SWF(frameRate="25", width="840", height="1267")]
	public class SchoolCompete extends Sprite {
		
		[Embed(source="images/017.png")]
		public static var BuilderSuccess: Class;
		[Embed(source="images/018.png")]
		public static var BuilderError: Class;
		[Embed(source="images/016.png")]
		public static var LoginIcon: Class;
		[Embed(source="images/015.png")]
		public static var ConfirmIcon: Class;
		
		public static const WIDTH: int = 840;
		public static const HEIGHT: int = 1267;
		public static const PADDING_V: int = 10;
		public static const PADDING_H: int = 10;
		public static const BORDER: int = 2;
		// 预览区域宽度
		public static const PEWVIEW_WIDTH: int = 428;
		// public static const PEWVIEW_HEIGHT: int = 680;
		public static const PEWVIEW_HEIGHT: int = 867;
		public static const PREVIEW_BG_WIDTH: int = 412;
		public static const PREVIEW_BG_HEIGHT: int = 787;
		public static const EDITER_X: int = 27;
		public static const EDITER_Y: int = 88;
		public static const EDITER_WIDTH: int = 360;
		public static const EDITER_HEIGHT: int = 600;
		// 上传区域宽度
		public static const UPLOAD_WIDTH: int = 390;
		public static const UPLOAD_HEIGHT: int = 640;
		public static const DEV_UPLOAD_HEIGHT: int = 720;
		// 上传显示列数.
		public static const UPLOAD_ITEM_SIZE: int = 6;
		// 上传项的参数
		public static const UPLOAD_ITEM_WIDTH: int = 56;
		public static const UPLOAD_ITEM_HEIGHT: int = 68;
		public static const UPLOAD_ITEM_LABEL_HEIGHT: int = 20;
		public static const UPLOAD_ITEM_PADDING_V: int = 8;
		public static const UPLOAD_ITEM_PADDING_H: int = 8;
		public static const UPLOAD_LABEL_HEIGHT: int = 24;
		// 提示框的尺寸.
		public static const TIP_WIDTH: int = 200;
		public static const TIP_HEIGHT: int = 160;
		public static const TIP_HEAD_HEIGHT: int = 16;
		public static const TIP_HEAD_WIDTH: int = 24;
		public static const TIP_ROUND: int = 4;
		// 主题信息区域的尺寸
		public static const THEME_INFO_WIDTH: int = 760;
		public static const THEME_INFO_HEIGHT: int = 328;
		// 主题打包的提示信息.
		public static const BUILDER_TIP_WIDTH: int = 360;
		public static const BUILDER_TIP_HEAD_HEIGHT: int = 16;
		public static const BUILDER_TIP_HEAD_WIDTH: int = 24;
		public static const BUILDER_TIP_ROUND: int = 8;
		public static const BUILDER_TIP_ROW_HEIGHT: int = 24;
		// 打包进度请求次数
		public static const BUILDER_STATUS_SIZE: int = 3;
		
		private var _list: UploadList;
		private var _info: ThemeInfo;
		
		private var _checkbox: CheckBox;
		private var _agreement: Input;
		private var _builderBtn: BuildButton;
		private var _alert: Dialog;
		// 上传是否准备完毕
		private var _uploadReady: Boolean;
		// 内容填写完毕.
		private var _infoReady: Boolean;
		// 时钟天气定制完毕.
		private var _weatherReady: Boolean;
		// 版权标签
		private var _copyLab: TextField;
		// 打包的当前进度.
		private var _builderStatus: int;
		// 打包的模拟效果。
		private var _builderAnimate: Timer;
		// 开始制作的提示.
		private var _builderTip: BuilderTip;
		// 开始制作的提示信息.
		private var _builderTipTxts: Array;
		// 时钟天气widget数组
		private var _weathers: Object;
		private var _currentWeather: WeatherWidget;
		
		// 所有打包数据.
		private var _data: Object;
		// 打包的请求对象.
		private var _builderLoader: URLLoader;
		// 用户数据请求对象.
		private var _userLoader: URLLoader;
		// 打包进度请求对象
		private var _builderStatLoader: URLLoader;
		
		// 加载效果
		private var _loading: Sprite;
		private var _loadEffect: Sprite;
		private var _builderSuccess: Bitmap;
		private var _builderError: Bitmap;
		private var _builderErrorLabel: TextField;
		private var _loginBg: Bitmap;
		private var _confirmBg: Bitmap;
		private var _loadLabel: TextField;
		private var _loadProg: TextField;
		// 打包进度请求次数.
		private var _builderStatusIndex: int;
		
		private var _downloadCallback: String;
		// 预览
		private var _preview: Preview;
		
		// 打包进度条计时器
		private var _builderTimer: Timer;
		// 打包ID;
		private var _builderId: String;
		// 打包主题ID
		private var _diyId: String;
		// 完善个人信息
		private var _userInfoBtn: ViewButton;
		// 我的收益
		private var _myProfitsBtn: ViewButton;
		// 我的作品
		private var _myWorksBtn: ViewButton;
		// 打包失败重新打包。
		private var _builderRebuilderBtn: ViewButton;
		// 登录按钮.
		private var _loginBtn: ViewButton;
		// 打包完成后的关闭按钮.
		private var _builderCloseBtn: ViewButton;
		// 打包完成后的完成按钮
		private var _builderFinsihBtn: ViewButton;
		// 开始制作的确认按钮
		private var _submitBtn: ViewButton;
		// 开始做作的取消按钮
		private var _cancelSubmitBtn: ViewButton;
		// 清空的提示.
		private var _clearConfirm: Confirm;
		
		public function SchoolCompete() {
			Security.allowDomain('*');
			Security.loadPolicyFile("http://p0.qhimg.com/crossdomain.xml");
			Security.loadPolicyFile("http://p1.qhimg.com/crossdomain.xml");
			Security.loadPolicyFile("http://p2.qhimg.com/crossdomain.xml");
			Security.loadPolicyFile("http://p3.qhimg.com/crossdomain.xml");
			Security.loadPolicyFile("http://p4.qhimg.com/crossdomain.xml");
			Security.loadPolicyFile("http://p5.qhimg.com/crossdomain.xml");
			Security.loadPolicyFile("http://p6.qhimg.com/crossdomain.xml");
			Security.loadPolicyFile("http://p7.qhimg.com/crossdomain.xml");
			Security.loadPolicyFile("http://p8.qhimg.com/crossdomain.xml");
			Security.loadPolicyFile("http://p9.qhimg.com/crossdomain.xml");
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align  = StageAlign.TOP_LEFT;
			
			if (root.loaderInfo && root.loaderInfo.parameters) {
				if (root.loaderInfo.parameters['path'])
					Terminal.host = root.loaderInfo.parameters['path'];
				if (root.loaderInfo.parameters['categorys'])
					Terminal.categorys = root.loaderInfo.parameters['categorys'];
				if (root.loaderInfo.parameters['prices'])
					Terminal.prices = root.loaderInfo.parameters['prices'];
				if (root.loaderInfo.parameters['download'])
					_downloadCallback = root.loaderInfo.parameters['download'];
				if (root.loaderInfo.parameters['proxy'])
					Terminal.proxy = root.loaderInfo.parameters['proxy'];
				if (root.loaderInfo.parameters['uuid'])
					Terminal.uuid = root.loaderInfo.parameters['uuid'];
				if (root.loaderInfo.parameters['doLogin'])
					Terminal.loginCallback = root.loaderInfo.parameters['doLogin'];
				if (root.loaderInfo.parameters['dev'])
					Terminal.dev = root.loaderInfo.parameters['dev'];
				if (root.loaderInfo.parameters['isPkg'])
					Terminal.isPkg = root.loaderInfo.parameters['isPkg'];
				if (root.loaderInfo.parameters['source'])
					Terminal.source = root.loaderInfo.parameters['source'];
				if (root.loaderInfo.parameters['pid'])
					Terminal.pid = root.loaderInfo.parameters['pid'];
				if (root.loaderInfo.parameters['userInfo'])
					Terminal.userInfo = root.loaderInfo.parameters['userInfo'];
				if (root.loaderInfo.parameters['userInfoCk'])
					Terminal.userInfoCk = root.loaderInfo.parameters['userInfoCk'];
				if (root.loaderInfo.parameters['profitsCk'])
					Terminal.profitsCk = root.loaderInfo.parameters['profitsCk'];
				if (root.loaderInfo.parameters['worksCk'])
					Terminal.worksCk = root.loaderInfo.parameters['worksCk'];
				if (root.loaderInfo.parameters['userName'])
					Terminal.userName = root.loaderInfo.parameters['userName'];
				if (root.loaderInfo.parameters['themeName'])
					Terminal.themeName = root.loaderInfo.parameters['themeName'];
				if (root.loaderInfo.parameters['themeDesc'])
					Terminal.themeDesc = root.loaderInfo.parameters['themeDesc'];
				if (root.loaderInfo.parameters['price'])
					Terminal.price = root.loaderInfo.parameters['price'];
				if (root.loaderInfo.parameters['category'])
					Terminal.category = root.loaderInfo.parameters['category'];
				if (root.loaderInfo.parameters['pkg'])
					Terminal.pkg = root.loaderInfo.parameters['pkg'];
				
				if (root.loaderInfo.parameters['enquireUrl'])
					Terminal.status = root.loaderInfo.parameters['enquireUrl'];
				if (root.loaderInfo.parameters['builderUrl'])
					Terminal.builder = root.loaderInfo.parameters['builderUrl'];
				if (root.loaderInfo.parameters['uploadUrl'])
					Terminal.upload = root.loaderInfo.parameters['uploadUrl'];
				if (root.loaderInfo.parameters['uuidUrl'])
					Terminal.uuidPath = root.loaderInfo.parameters['uuidUrl'];
				if (root.loaderInfo.parameters['clearUrl'])
					Terminal.clear = root.loaderInfo.parameters['clearUrl'];
				if (root.loaderInfo.parameters['downloadUrl'])
					Terminal.download = root.loaderInfo.parameters['downloadUrl'];
				
				if (root.loaderInfo.parameters['versionCode'])
					Terminal.versionCode = root.loaderInfo.parameters['versionCode'];
				
				if (root.loaderInfo.parameters['isInfoDesable'])
					Terminal.isInfoEdit = root.loaderInfo.parameters['isInfoDesable'] ? false : true;
				if (root.loaderInfo.parameters['finish'])
					Terminal.finish = root.loaderInfo.parameters['finish'];
				if (root.loaderInfo.parameters['finishCk'])
					Terminal.finishCk = root.loaderInfo.parameters['finishCk'];
				if (root.loaderInfo.parameters['builderError'])
					Terminal.builderErrorCallback = root.loaderInfo.parameters['builderError'];
				if (root.loaderInfo.parameters['apkPath'])
					Terminal.apkPath = root.loaderInfo.parameters['apkPath'];
				if (root.loaderInfo.parameters['dataCk'])
					Terminal.initDataCallback = root.loaderInfo.parameters['dataCk'];
				if (root.loaderInfo.parameters['widgetInfo']) {
					Terminal.initWidgetCk = root.loaderInfo.parameters['widgetInfo'];
					Terminal.widget = new JSONDecoder(ExternalInterface.call(Terminal.initWidgetCk)).getValue();
					if (root.loaderInfo.parameters['widgetCk'])
						Terminal.initWidgetCallback = root.loaderInfo.parameters['widgetCk'];
				}
				// 加载主题的terminal。
				if (root.loaderInfo.parameters['themeCk']) {
					Terminal.themeTerminalCk = root.loaderInfo.parameters['themeCk'];
					Terminal.terminal = new JSONDecoder(ExternalInterface.call(Terminal.themeTerminalCk)).getValue();
				}
				
				// 加载主题编辑项的配置信息。
				if (root.loaderInfo.parameters['themeEditerCk']) {
					Terminal.themeEditerCk = root.loaderInfo.parameters['themeEditerCk'];
					Terminal.items = new JSONDecoder(ExternalInterface.call(Terminal.themeEditerCk)).getValue();
				}
				Terminal.items = Terminal.items.editer;
			}
			
			// 绘制加载效果
			_loading = new Sprite();
			_loading.graphics.lineStyle(2, 0x777777);
			_loading.graphics.beginFill(0xFFFFFF, 0.9);
			_loading.graphics.drawRoundRect(0, 0, 400, 240, 8);
			_loading.graphics.endFill();
			
			_loadEffect = new Sprite();
			_loadEffect.addChild(makeLoadShape(.1, 0));
			_loadEffect.addChild(makeLoadShape(.2, 12));
			_loadEffect.addChild(makeLoadShape(.3, 24));
			_loadEffect.addChild(makeLoadShape(.4, 36));
			_loadEffect.addChild(makeLoadShape(.5, 48));
			_loadEffect.addChild(makeLoadShape(.6, 60));
			_loadEffect.addChild(makeLoadShape(.7, 72));
			_loadEffect.addChild(makeLoadShape(.8, 84));
			_loadEffect.addChild(makeLoadShape(.9, 96));
			_loadEffect.addChild(makeLoadShape(1, 108));
			_loadEffect.x = 200;
			_loadEffect.y = 96;
			_loading.addChild(_loadEffect);
			
			_builderSuccess = new BuilderSuccess();
			_builderSuccess.x = 100;
			_builderSuccess.y = 8;
			_builderSuccess.visible = false;
			_loading.addChild(_builderSuccess);
			
			_builderError = new BuilderError();
			_builderError.x = 100;
			_builderError.y = 8;
			_builderError.visible = false;
			_loading.addChild(_builderError);
			
			_builderErrorLabel = new TextField();
			_builderErrorLabel.text = '制作失败\n您制作失败的可能原因有以下几种：' +
				'\n1.图片格式不符合主题规范要求；' +
				'\n2.修改图片后缀名（如将icon.jpg 的图片直接修改为\n   icon.png），图片格式必须是PS软件直接存储的格式；' +
				'\n3.网络超时；';
			_builderErrorLabel.setTextFormat(TextFormats.THEME_INFO_SPECIFICATION_TITLE, 0, 5);
			_builderErrorLabel.setTextFormat(TextFormats.THEME_INFO_SPECIFICATION, 5, 31);
			_builderErrorLabel.setTextFormat(TextFormats.THEME_INFO_SPECIFICATION_LINK, 31, 35);
			_builderErrorLabel.setTextFormat(TextFormats.THEME_INFO_SPECIFICATION, 35, _builderErrorLabel.text.length);
			_builderErrorLabel.x = 42;
			_builderErrorLabel.y = 24;
			_builderErrorLabel.width = 316;
			_builderErrorLabel.height = 184;
			_builderErrorLabel.visible = false;
			_loading.addChild(_builderErrorLabel);
			
			_loginBg = new LoginIcon();
			_loginBg.x = 100;
			_loginBg.y = 8;
			_loginBg.visible = false;
			_loading.addChild(_loginBg);
			
			_confirmBg = new ConfirmIcon();
			_confirmBg.x = 100;
			_confirmBg.y = 8;
			_confirmBg.visible = false;
			_loading.addChild(_confirmBg);
			
			_loadProg = new TextField();
			_loadProg.x = 180;
			_loadProg.y = 86;
			_loadProg.width = 40;
			_loadProg.height = 20;
			_loadProg.mouseEnabled = false;
			_loading.addChild(_loadProg);
			
			_loadLabel = new TextField();
			_loadLabel.x = 20;
			_loadLabel.y = 168;
			_loadLabel.width = 360;
			_loadLabel.height = 20;
			_loadLabel.mouseEnabled = false;
			_loading.addChild(_loadLabel);
			
			_userInfoBtn = new ViewButton('完善个人信息');
			_userInfoBtn.x = 400 - 36 - ViewButton.WIDTH * 2 >> 1;
			_userInfoBtn.y = 196;
			_loading.addChild(_userInfoBtn);
			_userInfoBtn.addEventListener(MouseEvent.CLICK, function(evt: MouseEvent): void {
				ExternalInterface.call(Terminal.userInfoCk);
			});
			_userInfoBtn.visible = false;

			_myProfitsBtn = new ViewButton('我的收益');
			_myProfitsBtn.x = 400 - 36 - ViewButton.WIDTH * 2 >> 1;
			_myProfitsBtn.y = 196;
			_loading.addChild(_myProfitsBtn);
			_myProfitsBtn.addEventListener(MouseEvent.CLICK, function(evt: MouseEvent): void {
				ExternalInterface.call(Terminal.profitsCk);		
			});
			_myProfitsBtn.visible = false;

			_myWorksBtn = new ViewButton('我的作品');
			_myWorksBtn.x = 400 - _userInfoBtn.x - ViewButton.WIDTH;
			_myWorksBtn.y = 196;
			_loading.addChild(_myWorksBtn);
			_myWorksBtn.addEventListener(MouseEvent.CLICK, function(evt: MouseEvent): void {
				ExternalInterface.call(Terminal.worksCk);	
			});
			_myWorksBtn.visible = false;
			
			_builderRebuilderBtn = new ViewButton('重新打包');
			_builderRebuilderBtn.x = 400 - 36 - ViewButton.WIDTH * 2 >> 1;
			_builderRebuilderBtn.y = 196;
			_loading.addChild(_builderRebuilderBtn);
			_builderRebuilderBtn.addEventListener(MouseEvent.CLICK, function(evt: MouseEvent): void {
				doBuilder();			
			});
			_builderRebuilderBtn.visible = false;
			
			_builderCloseBtn = new ViewButton('关闭');
			_builderCloseBtn.x = 400 - _userInfoBtn.x - ViewButton.WIDTH;
			_builderCloseBtn.y = 196;
			_loading.addChild(_builderCloseBtn);
			_builderCloseBtn.addEventListener(MouseEvent.CLICK, function(evt: MouseEvent): void {
				hideLoading();
			});
			_builderCloseBtn.visible = false;
			
			_builderFinsihBtn = new ViewButton('完成');
			_builderFinsihBtn.x = 400 - _userInfoBtn.x - ViewButton.WIDTH;
			_builderFinsihBtn.y = 196;
			_loading.addChild(_builderFinsihBtn);
			_builderFinsihBtn.addEventListener(MouseEvent.CLICK, function(evt: MouseEvent): void {
				ExternalInterface.call(Terminal.finishCk);
				hideLoading();
			});
			_builderFinsihBtn.visible = false;
			
			_submitBtn = new ViewButton('确认提交');
			_submitBtn.x = 400 - 36 - ViewButton.WIDTH * 2 >> 1;
			_submitBtn.y = 196;
			_loading.addChild(_submitBtn);
			_submitBtn.addEventListener(MouseEvent.CLICK, function(evt: MouseEvent): void {
				doBuilder();
			});
			_submitBtn.visible = false;
			
			_cancelSubmitBtn = new ViewButton('取消提交');
			_cancelSubmitBtn.x = 400 - _userInfoBtn.x - ViewButton.WIDTH;
			_cancelSubmitBtn.y = 196;
			_loading.addChild(_cancelSubmitBtn);
			_cancelSubmitBtn.addEventListener(MouseEvent.CLICK, function(evt: MouseEvent): void {
				hideLoading();
			});
			_cancelSubmitBtn.visible = false;
			
			_alert = new Dialog(new Rectangle(0, 0, WIDTH, HEIGHT));
			
			// 用户相关请求对象初始化.
			_userLoader = new URLLoader();
			_userLoader.addEventListener(Event.COMPLETE, doClear);
			
			_loginBtn = new ViewButton("登录");
			_loginBtn.x = 400 - ViewButton.WIDTH >> 1;
			_loginBtn.y = 196;
			_loading.addChild(_loginBtn);
			_loginBtn.addEventListener(MouseEvent.CLICK, function(evt: MouseEvent): void {
				ExternalInterface.call(Terminal.loginCallback, "login");
			});
			_loginBtn.visible = false;
			// 用户信息初始化
			addEventListener(Event.ADDED_TO_STAGE, function (): void {
trace ('uuid : ' + Terminal.uuid);
				if (Terminal.uuid == null || Terminal.uuid == '') {
					updateLoading(-3);
				} else {
					_loginBtn.visible = false;
					_loginBg.visible = false;
				}
			});
			
			/** 打包请求. */
			_builderLoader = new URLLoader();
			_builderLoader.addEventListener(IOErrorEvent.IO_ERROR, function (evt: IOErrorEvent): void {
				updateLoading(-1);
			});
			_builderLoader.addEventListener(HTTPStatusEvent.HTTP_STATUS, function (evt: HTTPStatusEvent): void {
trace ('_builderLoader : ' + evt.status);
			});
			_builderLoader.addEventListener(Event.COMPLETE, function (evt: Event): void {
trace ('_builderLoader : ' + _builderLoader.data.toString());
				var strs: Array = _builderLoader.data.toString().split('|');
				_builderStatusIndex = 0;
				// uid|taskId|diyId
				if (strs.length > 2) {
					_builderId = strs[1];
					_diyId = strs[2];
					_builderTimer.reset();
					_builderTimer.start();
				} else {
					// 去掉了提示，改用统一提示。
					// _list.alert(strs[1]);
					updateLoading(-1);
					_builderAnimate.running && _builderAnimate.stop();
				}
			});
			
			_alert = new Dialog(new Rectangle(0, 0, WIDTH, HEIGHT));
			_alert.x = 0;
			_alert.y = 0;
			addChild(_alert);
			_alert.hide();
			
			_preview = new Preview(this);
			_preview.x = PADDING_H;
			_preview.y = PADDING_V * 2 + THEME_INFO_HEIGHT;
			addChild(_preview);
			
			// 时钟天气的相关调整。
			_weathers = {};
			var wz: Number = EDITER_WIDTH / Utils._width, 
				hz: Number = EDITER_HEIGHT / Utils._height,
				zoom: Number = wz < hz ? wz : hz, weatherIndex: int = 0;
			for (var weatherMode: String in Terminal.widget) {
				var weather: WeatherWidget = new WeatherWidget(weatherMode, Terminal.widget[weatherMode], zoom, this);
				weather.x = (_preview.x + EDITER_X) + 4 * zoom;
				weather.y = (_preview.y + EDITER_Y) + 64 * zoom;
				_weathers[weatherMode] = weather;
				if (!weatherIndex) {
					weather.visible = true;
					_currentWeather = weather;
				} else {
					weather.visible = false;
				}
				weatherIndex ++;
			}
			
			
			// 打包进度的请求.
			_builderTimer = new Timer(1000, 1);
			_builderTimer.addEventListener(TimerEvent.TIMER, function (evt: TimerEvent): void {
trace (Terminal.host + Terminal.status + '?taskId=' + _builderId + '&diyId=' + _diyId + 
	'&progress=' + _builderStatus + '&d=' + new Date().time);
				_builderStatLoader.load(new URLRequest(Terminal.host + Terminal.status + 
					'?taskId=' + _builderId + '&diyId=' + _diyId + '&tpid=' + Terminal.pid +
					'&source=' + Terminal.source + '&pid=' + Terminal.pid +
					'&progress=' + _builderStatus + '&d=' + new Date().time));
			});
			
			_builderStatLoader = new URLLoader();
			_builderStatLoader.addEventListener(IOErrorEvent.IO_ERROR, function (evt: IOErrorEvent): void {
				if (_builderStatusIndex < BUILDER_STATUS_SIZE) {
					_builderTimer.reset();
					_builderTimer.start();
					ExternalInterface.call(Terminal.builderErrorCallback, evt.type, evt.text);
					_builderStatusIndex ++;
				} else {
					updateLoading(-1);
				}
			});
			_builderStatLoader.addEventListener(HTTPStatusEvent.HTTP_STATUS, function (evt: HTTPStatusEvent): void {
trace ('_builderStatLoader : ' + evt.status);
			});
			_builderStatLoader.addEventListener(Event.COMPLETE, function (evt: Event): void {
				var strs: Array = _builderStatLoader.data.toString().split('|');
trace ('_builderStatLoader : ' + _builderStatLoader.data.toString());
				if (strs[1] >= 100) {
					updateLoading(strs[1]);
					_builderId = strs[0];
				} else {
					if (strs[1] < 0) {
						updateLoading(strs[1]);
					} else {
						doLoading(strs[1]);
						_builderTimer.reset();
						_builderTimer.start();
					}
				}
			});
			
			_clearConfirm = new Confirm('是否确认清空?', function (): void {
				_userLoader.load(new URLRequest(Terminal.host + Terminal.clear + '?d=' + new Date().time));
				// _info.clear();
				_list.clear();
				_preview.clear();
				_data = {};
				hideClearConfirm();
			}, function (): void {
				hideClearConfirm();
			}, 300, 180);
			
			// 打包进度条动画
			_builderAnimate = new Timer(1000, 1);
			_builderAnimate.addEventListener(TimerEvent.TIMER, function (evt: TimerEvent): void {
				if (_builderStatus < 80 && _builderStatus > 0) {
					doLoading(_builderStatus + 5);
					_builderAnimate.reset();
					_builderAnimate.start();
				}
			});
			_data = {};
			Init(null);
		}
		
		/** 清空确认的提示. */
		public function doClearConfirm(): void {
			alert(_clearConfirm);
		}
		public function hideClearConfirm(): void {
			close();
		}
		
		/** 显示加载界面. */
		public function doLoading(prog: int = -1): void {
			_info.enable = false;
			updateLoading(prog);
			addEventListener(Event.ENTER_FRAME, loadAnimation);
		}
		/** 隐藏加载界面. */
		public function hideLoading(): void {
			_info.enable = true;
			removeEventListener(Event.ENTER_FRAME, loadAnimation);
			_builderCloseBtn.visible = false;
			_builderFinsihBtn.visible = false;
			_userInfoBtn.visible = false;
			_myProfitsBtn.visible = false;
			_myWorksBtn.visible = false;
			_builderSuccess.visible = false;
			_loadEffect.visible = true;
			_submitBtn.visible = false;
			_cancelSubmitBtn.visible = false;
			close();
		}
		/** 更新加载界面文字. */
		public function updateLoading(prog: int = -1): void {
			_builderStatus = prog;
			_confirmBg.visible = false;
			_builderError.visible = false;
			_builderSuccess.visible = false;
			_loadEffect.visible = false;
			_builderRebuilderBtn.visible = false;
			_userInfoBtn.visible = false;
			_myProfitsBtn.visible = false;
			_myWorksBtn.visible = false;
			_builderCloseBtn.visible = false;
			_builderFinsihBtn.visible = false;
			_submitBtn.visible = false;
			_cancelSubmitBtn.visible = false;
			_loginBg.visible = false;
			_loginBtn.visible = false;
			_builderErrorLabel.visible = false;
			if (prog >= 0 && prog < 100) {
				_loadProg.text = prog + '%';
				_loadProg.setTextFormat(TextFormats.ALERT_FORMAT);
				_loadLabel.text = "打包中，请稍候...";
				_loadLabel.setTextFormat(TextFormats.ALERT_FORMAT);
				_loadEffect.visible = true;
			} else {
				if (prog >= 100) {
					_loadLabel.text = "打包完成。";
					_loadLabel.setTextFormat(TextFormats.ALERT_FORMAT);
					_builderSuccess.visible = true;
					_builderAnimate.running && _builderAnimate.stop();
					if (Terminal.finish) {
						ExternalInterface.call(Terminal.finish);
					} else {
						if (Terminal.userInfo == 0) {
							_userInfoBtn.visible = true;
						} else {
							_myProfitsBtn.visible = true;
						}
						_myWorksBtn.visible = true;
						_builderFinsihBtn.visible = true;
					}
				} else {
					if (prog == -1) {
						_loadLabel.text = "";
						_loadLabel.setTextFormat(TextFormats.ALERT_ERROR_FORMAT);
						// _builderError.visible = true;
						_builderErrorLabel.visible = true;
						_builderCloseBtn.visible = true;
						_builderRebuilderBtn.visible = true;
						_builderAnimate.running && _builderAnimate.stop();
					} else if (prog == -2) {
						_loadLabel.text = '初始化中...';
						_loadLabel.setTextFormat(TextFormats.ALERT_FORMAT);
						_loadEffect.visible = true;
					} else if (prog == -3) {
						_loadLabel.text = '您还未登录哟~';
						_loadLabel.setTextFormat(TextFormats.ALERT_FORMAT);
						_loginBtn.visible = true;
						_loginBg.visible = true;
					} else if (prog == -4) {
						_loadLabel.text = '您的主题提交制作审核后，主题将不能进行修改。';
						_loadLabel.setTextFormat(TextFormats.ALERT_FORMAT);
						_confirmBg.visible = true;
						_submitBtn.visible = true;
						_cancelSubmitBtn.visible = true;
					}
				}
				_loadProg.text = '';
			}
			alert(_loading);
		}
		
		/** 绘制一个旋转效果. */
		private function makeLoadShape(a: Number = 1, r: Number = 0): Shape {
			var shape: Shape = new Shape();
			shape.graphics.lineStyle(1, 0x333333, a);
			shape.graphics.beginFill(0x999999, a);
			shape.graphics.drawRect(-40, -2, 20, 4);
			shape.graphics.drawRect(20, -2, 20, 4);
			shape.graphics.endFill();
			shape.rotation = r;
			return shape;
		}
		
		/** 清理用户数据后的回调. */
		private function doClear(evt: Event): void {
			
		}
		
		/** 加载的动画. */
		private function loadAnimation(evt: Event): void {
			_loadEffect.rotation += 15;
		}
		
		private function Init(evt: Event): void {
			_builderBtn = new BuildButton("提交审核");
			_info = new ThemeInfo(this);
			_info.x = PADDING_H;
			_info.y = PADDING_V;
			
			_list = new UploadList(this);
			_list.x = PADDING_H + PEWVIEW_WIDTH;
			_list.y = PADDING_V * 2 + THEME_INFO_HEIGHT;
			
			var btnY: int = HEIGHT - ViewButton.HEIGHT - 80;
			_builderBtn.x = _list.x + (UPLOAD_WIDTH - ViewButton.WIDTH - 32 >> 1);
			_builderBtn.y = btnY;
			addChild(_builderBtn);
			_builderBtn.addEventListener(MouseEvent.CLICK, function(evt: MouseEvent): void {
				if (_builderBtn.enable)
					updateLoading(-4);					
			});
			_builderBtn.addEventListener(MouseEvent.MOUSE_OVER, function (evt: MouseEvent): void {
				if (_builderTipTxts && _builderTipTxts.length) {
					_builderTip.update(_builderTipTxts);
					_builderTip.visible = true;
				}
			});
			_builderBtn.addEventListener(MouseEvent.MOUSE_OUT, function (evt: MouseEvent): void {
				_builderTip.visible = false;
			});
			_builderTip = new BuilderTip();
			_builderTip.x = _builderBtn.x + (BuildButton.WIDTH >> 1);
			_builderTip.y = _builderBtn.y;
			
			_checkbox = new CheckBox(20, 19);
			_checkbox.x = _list.x + 60;
			_checkbox.y = btnY - 36;
			addChild(_checkbox);
			_checkbox.addEventListener(MouseEvent.CLICK, function (evt: MouseEvent): void {
				readyBuild();
			});
			
			_agreement = new Input(240, 20);
			_agreement.x = _checkbox.x + 23;
			_agreement.y = _checkbox.y;
			_agreement.border = false
			_agreement.setFormat(TextFormats.AGREEMENT_FORMAT);
			_agreement.text = "同意360主题达人联盟设计师协议"
			addChild(_agreement);
			
			_copyLab = new TextField();
			_copyLab.htmlText = "360手机桌面主题美化工具(v1.0)";
			_copyLab.setTextFormat(TextFormats.COPY_LABEL_FORMAT);
			_copyLab.width = 180;
			_copyLab.height = 18;
			_copyLab.x = WIDTH - 196;
			_copyLab.y = HEIGHT - 34;
			_copyLab.addEventListener(MouseEvent.MOUSE_OVER, function (evt: MouseEvent): void {
				_copyLab.setTextFormat(TextFormats.COPY_LABEL_HOVER_FORMAT);
			});
			_copyLab.addEventListener(MouseEvent.MOUSE_OUT, function (evt: MouseEvent): void {
				_copyLab.setTextFormat(TextFormats.COPY_LABEL_FORMAT);
			});
			for (var weatherMode: String in _weathers)
				addChild(_weathers[weatherMode]);
			addChild(_copyLab);
			addChild(_info);
			addChild(_list);
			addChild(_builderTip);
			
			draw();
			_list.updateUploads();
			
			// 初始化数据
			if (Terminal.initDataCallback) {
				try {
					var initData: String = ExternalInterface.call(Terminal.initDataCallback),
						data: Object = new JSONDecoder(initData).getValue();
					for (var pack: String in data)
						_list.setItme(pack, data[pack]);
				} catch (e: Error) {}
			}
			if (Terminal.initWidgetCallback) {
				try {
					var widgetData: String = ExternalInterface.call(Terminal.initWidgetCallback),
						wData: Object = new JSONDecoder(widgetData).getValue();
					if (wData['theme']) {
						weatherModeChange(wData['theme']);
						for (var file: String in wData) {
							if (file != 'theme') {
								var widgetItem: Object = wData[file];
								if (widgetItem['size'])
									this.updateWeatherSize(file, widgetItem['size']);
								if (widgetItem['color'])
									this.updateWeatherColor(file, uint('0x' + widgetItem['color'].replace('#', '')));
								if (widgetItem['shadow_color'])
									this.updateWeatherShadowColor(file, uint('0x' + widgetItem['shadow_color'].replace('#', '')));
								if (widgetItem['shadow_radius'])
									this.updateWeatherShadowFuzzy(file, widgetItem['shadow_radius']);
								if (widgetItem['shadow_dx'])
									this.updateWeatherShadowX(file, widgetItem['shadow_dx']);
								if (widgetItem['shadow_dy'])
									this.updateWeatherShadowY(file, widgetItem['shadow_dy']);
							}
						}
						_list.updateWidgetMode(wData['theme'], wData);
					}
				} catch (e: Error) {}
			}
			
			// 测试widget编辑
			/*
			var wData: Object = Terminal.widgetInit;
			if (wData['theme']) {
				weatherModeChange(wData['theme']);
				for (var file: String in wData) {
					if (file != 'theme') {
						var widgetItem: Object = wData[file];
						if (widgetItem['size'])
							this.updateWeatherSize(file, widgetItem['size']);
						if (widgetItem['color'])
							this.updateWeatherColor(file, uint('0x' + widgetItem['color'].replace('#', '')));
						if (widgetItem['shadow_color'])
							this.updateWeatherShadowColor(file, uint('0x' + widgetItem['shadow_color'].replace('#', '')));
						if (widgetItem['shadow_radius'])
							this.updateWeatherShadowFuzzy(file, widgetItem['shadow_radius']);
						if (widgetItem['shadow_dx'])
							this.updateWeatherShadowX(file, widgetItem['shadow_dx']);
						if (widgetItem['shadow_dy'])
							this.updateWeatherShadowY(file, widgetItem['shadow_dy']);
					}
				}
				_list.updateWidgetMode(wData['theme'], wData);
			}
			*/
			readyBuild();
		}
		
		/** 打包操作. */
		public function doBuilder(): void {
			var request: URLRequest = new URLRequest(Terminal.host + Terminal.builder);
			var variables:URLVariables = new URLVariables();
			variables['source'] = Terminal.source || '';
			variables['pid'] = Terminal.pid || '';
			variables['uid'] = Terminal.uuid || '';
			variables['versionCode'] = Terminal.versionCode || '';
			variables['name'] = _info.author || '';
			variables['theme'] = _info.theme || '';
			variables['desc'] = _info.desc || '';
			variables['pkg'] = _info.pkg || '';
			variables['price'] = _info.price || '';
			variables['cate'] = _info.category || '';
			variables['data'] = _list.addToString({'apk': _info.apk}) || '';
			variables['weatherWidget'] = _currentWeather.toString() || '';
			variables['dev'] = Terminal.dev;
			request.method = URLRequestMethod.POST;
			request.data = variables;
			_builderLoader.load(request);
			doLoading(5);
			_builderAnimate.reset();
			_builderAnimate.start();
		}
		
		private function draw(): void {
			var g: Graphics = this.graphics;
			g.beginFill(0xffffff, 1);
			g.drawRect(0, 0, WIDTH, HEIGHT);
			g.lineStyle(1, 0xf0f0f0, 1);
			g.beginFill(0xfafafa, 1);
			g.drawRoundRect(PADDING_H, PADDING_V + THEME_INFO_HEIGHT, 
				WIDTH - PADDING_H * 2, HEIGHT - PADDING_V * 2 - THEME_INFO_HEIGHT, BORDER << 2);
			g.moveTo(BORDER << 2, THEME_INFO_HEIGHT);
			g.lineStyle(BORDER, 0xe6e6e6, 1);
			g.lineTo(WIDTH - BORDER * 5, THEME_INFO_HEIGHT);
			g.endFill();
		}
		
		/** 内容上传完毕，准备打包. */
		public function readyBuild(): void {
			if (!_builderBtn)
				return;
			if (Terminal.dev) {
				_builderBtn.buttonMode = _builderBtn.enable = true;
			} else {
				_builderTipTxts = [];
				if (_uploadReady && _infoReady && _checkbox.selected && _weatherReady) {
					_builderBtn.buttonMode = _builderBtn.enable = true;
				}
				else {
					_builderBtn.buttonMode = _builderBtn.enable = false;
					_builderTipTxts.push('还不能开始制作，原因：');
					if (!_uploadReady)
						_builderTipTxts.push(' * 必选主题图标项还有未上传的图标');
					if (!_infoReady)
						_builderTipTxts.push(' * 主题基本信息不完整（名称、作者、描述都要填写）');
					if (_checkbox && !_checkbox.selected)
						_builderTipTxts.push(' * 未接受360主题达人联盟设计师协议1');
					if (!_weatherReady)
						_builderTipTxts.push(' * 还有未定制的工具项');
				}
			}
			// 测试界面用
			// updateLoading(-1);
		}
		/** 内容上传完毕. */
		public function  set readyUpload(b: Boolean): void {
			_uploadReady = b;
			readyBuild();
		}
		/** 主题信息填写完毕. */
		public function set readyInfo(b: Boolean): void {
			_infoReady = b;
			readyBuild();
		}
		/** 时钟天气定制完毕. */
		public function setWeatherReady(b: Boolean, elem: WeatherWidget): void {
			if (elem != _currentWeather) return;
			_weatherReady = b;
			readyBuild();
		}
		/** 文字提示框. */
		public function console(txt: String): void {
			_list.alert(txt);
		}
		/** 显示提示框. */
		public function alert(view: DisplayObject): void {
			_alert.update(view);
		}
		/** 关闭提示框. */
		public function close(): void {
			_alert.hide();
		}
		/** 获取数据. */
		public function data(pack: String): String {
			return _data[pack];
		}
		/** 更新数据. */
		public function update(pack: String, url: String): void {
			_data[pack] = url;
			_preview.updateAt(pack, url);
		}
		/** 更新时钟天气widget的数据. */
		public function updateWeather(pack: String, url: String, mode: String = null): void {
			if (mode && _weathers[mode])
				_weathers[mode].updateAt(pack, url);
			else
				_currentWeather.updateAt(pack, url);
		}
		public function updateWeatherColor(pack: String, color: uint, mode: String = null): void {
			if (mode && _weathers[mode])
				_weathers[mode].updateColor(pack, color);
			else
				_currentWeather.updateColor(pack, color);
		}
		public function updateWeatherSize(pack: String, size: int, mode: String = null): void {
			if (mode && _weathers[mode])
				_weathers[mode].updateSize(pack, size);
			else
				_currentWeather.updateSize(pack, size);
		}
		public function updateWeatherShadowColor(pack: String, color: uint, mode: String = null): void {
			if (mode && _weathers[mode])
				_weathers[mode].updateWeatherShadowColor(pack, color);
			else
				_currentWeather.updateWeatherShadowColor(pack, color);
		}
		public function updateWeatherShadowFuzzy(pack: String, size: int, mode: String = null): void {
			if (mode && _weathers[mode])
				_weathers[mode].updateWeatherShadowFuzzy(pack, size);
			else
				_currentWeather.updateWeatherShadowFuzzy(pack, size);
		}
		public function updateWeatherShadowY(pack: String, y: int, mode: String = null): void {
			if (mode && _weathers[mode])
				_weathers[mode].updateWeatherShadowY(pack, y);
			else
				_currentWeather.updateWeatherShadowY(pack, y);
		}
		public function updateWeatherShadowX(pack: String, x: int, mode: String = null): void {
			if (mode && _weathers[mode])
				_weathers[mode].updateWeatherShadowX(pack, x);
			else
				_currentWeather.updateWeatherShadowX(pack, x);
		}
		public function changeWeather(pack: String, mode: String = null): void {
			if (mode && _weathers[mode])
				_weathers[mode].changeWeather(pack);
			else
				_currentWeather.changeWeather(pack);
		}
		public function updateWeatherText(pack: String, txt: String, mode: String = null): void {
			if (mode && _weathers[mode])
				_weathers[mode].updateText(pack, txt);
			else
				_currentWeather.updateText(pack, txt);
		}
		public function weatherModeChange(mode: String): void {
			_currentWeather = _weathers[mode];
			for (var m: String in _weathers)
				_weathers[m].visible = false;
			_currentWeather.visible = true;
			_list.widgetModeChange(mode);
			setWeatherReady(_currentWeather.check(), _currentWeather);
		}
		
		/** widget加载时的处理. */
		public function doPreviewLoad(): void {
			
		}
		public function doPreviewLoaded(): void {
			
		}
		
		public function set view(v: String): void {
			if (_currentWeather.view == v) {
				_currentWeather.visible = true;
			} else {
				_currentWeather.visible = false;
			}
		}
	}
}
