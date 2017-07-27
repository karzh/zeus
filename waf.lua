local Waf = {argsRules={},urlRules={},blockHtml=""};

function Waf:new(o)
    o = o or {};
    setmetatable(o,self);
    self.__index = self;
    return o;
end

function Waf:readRules(path)
    file = io.open(path,"r");
    if file == nil then
        return;	    
    end
    t = {};
    for line in file:lines() do
	table.insert(t,line);
    end
    file:close();
    return (t);
end

function Waf:init(html)
    self.argsRules = self:readRules('/usr/luaproject/zeus/rules/args');
    if html~=nil then
	self.blockHtml = html;
    end
end

--waf过滤总函数
function Waf:filter()
--    ngx.say("filter");
      if self:checkArgs() then
	self:blockRequest();
      end
end

--返回拦截页面的函数
function Waf:blockRequest()
    ngx.header.content_type = "text/html";
    ngx.status = ngx.HTTP_FORBIDDEN;
    ngx.say(self.blockHtml);
    ngx.exit(ngx.status);
end

function Waf:log()
end

--过滤get请求参数值的函数
function Waf:checkArgs()
    
    for _,rule in pairs(self.argsRules) do
    	local reqArgs = ngx.req.get_uri_args();
	for key,val in pairs(reqArgs) do
	    if type(val) == 'table' then
		local t = {};
		for k,v in pairs(val) do
		    if v == true then
			v = "";
		    end
		    table.insert(t,v);
		end
		data = table.concat(t," ");
	    else
		data = val;
	    end
	    if data and type(data) ~= "boolean" and rule ~= "" and ngx.re.match(ngx.unescape_uri(data),rule,"isjo") then
		return true;
	    end
	end
    end
    return false;
end

function Waf:checkUrl()
end

function Waf:checkParam()
end

function Waf:checkHeaders()
end

function Waf:checkBody()
end

function Waf:checkCookie()
end

function Waf:checkUserAgent()
end

function Waf:checkFileExt()
end

local bh = [[
<html xmlns="http://www.w3.org/1999/xhtml"><head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<title>网站防火墙</title>
<style>
p {
		line-height:20px;
	}
	ul{ list-style-type:none;}
	li{ list-style-type:none;}
	</style>
	</head>
	<body style=" padding:0; margin:0; font:14px/1.5 Microsoft Yahei, 宋体,sans-serif; color:#555;">
	 <div style="margin: 0 auto; width:1000px; padding-top:70px; overflow:hidden;">
	   
	   
	   <div style="width:600px; float:left;">
	       <div style=" height:40px; line-height:40px; color:#fff; font-size:16px; overflow:hidden; background:#6bb3f6; padding-left:20px;">网站防火墙 </div>
	           <div style="border:1px dashed #cdcece; border-top:none; font-size:14px; background:#fff; color:#555; line-height:24px; height:220px; padding:20px 20px 0 20px; overflow-y:auto;background:#f3f7f9;">
		         <p style=" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px;"><span style=" font-weight:600; color:#fc4f03;">您的请求带有不合法参数，已被网站管理员设置拦截！</span></p>
			 <p style=" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px;">可能原因：您提交的内容包含危险的攻击请求</p>
			 <p style=" margin-top:12px; margin-bottom:12px; margin-left:0px; margin-right:0px; -qt-block-indent:1; text-indent:0px;">如何解决：</p>
			 <ul style="margin-top: 0px; margin-bottom: 0px; margin-left: 0px; margin-right: 0px; -qt-list-indent: 1;"><li style=" margin-top:12px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px;">1）检查提交内容；</li>
			 <li style=" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px;">2）如网站托管，请联系空间提供商；</li>
			 <li style=" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px;">3）普通网站访客，请联系网站管理员；</li></ul>
			     </div>
			       </div>
			       </div>
			       </body></html>
			       ]];
local w = Waf:new();
w:init(bh);
w:filter();
