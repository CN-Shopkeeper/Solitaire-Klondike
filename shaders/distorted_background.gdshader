shader_type canvas_item;

uniform vec3 colour1 : source_color = vec3(1.0, 0.0, 0.0);
uniform vec3 colour2 : source_color = vec3(0.0, 0.0, 1.0);
uniform vec3 colour3 : source_color = vec3(0.0, 0.0, 0.0); // 衔接颜色
uniform vec3 colour4 : source_color = vec3(1.0, 1.0, 1.0); // 起始/终点颜色
uniform int contrast : hint_range(0, 10, 1) = 5; // 过度强度
uniform float gradual : hint_range(0.0, 2.0, 0.01) = 2; // 渐变
uniform float width1 : hint_range(0.01, 1.0, 0.01) = 0.04; // 中间色宽度
uniform float width2 : hint_range(0.01, 1.0, 0.01) = 0.1; // 中间色宽度
uniform float scale1 : hint_range(0.0, 100.0, 0.1) = 10.0; // 缩放1
uniform float scale2 : hint_range(0.0, 10.0, 0.01) = 1.0; // 缩放2
uniform vec2 offset = vec2(0); // 偏移
uniform float intensity : hint_range(0.0, 4.0, 0.1) = 0.2; // 扭曲强度
uniform float spin_speed : hint_range(0.0, 10.0, 0.1) = 0.2; // 旋转速度
uniform float spin_amount : hint_range(0.0, 10.0, 0.1) = 1.5; // 旋转量

void fragment() {
	float speed = TIME * spin_speed;
	// 无拉伸屏幕 UV;
	vec2 uv = FRAGCOORD.xy * SCREEN_PIXEL_SIZE.y;
	// 居中 UV
	float center = SCREEN_PIXEL_SIZE.y/SCREEN_PIXEL_SIZE.x;
	uv.y -= 0.5;
	uv.x -= 0.5 * center;
	uv *= 2.0;
	uv += offset;
	float uv_len = length(uv);
	// 获得角度信息
	float angle = atan(uv.y, uv.x);
	// 根据距离衰减旋转
	angle -= spin_amount * uv_len;
	// 角度旋转动画
	angle += speed;
    // 根据距离应用旋转
	uv = vec2(uv_len * cos(angle), uv_len * sin(angle)) * scale2;
    // UV 扭曲效果
    uv *= scale1;
    vec2 uv2 = vec2(uv.x + uv.y);
    for (int i = 0; i < contrast; i++) {
		uv2 += sin(uv);
		uv += vec2(cos(intensity * uv2.y + speed), sin(intensity * uv2.x - speed));
        uv -= cos(uv.x + uv.y) - sin(uv.x - uv.y);
    }
	// 强度值
	float paint_res = smoothstep(0, gradual, length(uv) / scale1);
	// 色块划分
	float c3p = 1.0 - min(width2, abs(paint_res - 0.5)) * (1.0 / width2);
	float c_out =  max(0.0, (paint_res - (1.0 - width1))) * (1.0 / width1);
	float c_in =  max(0.0, -(paint_res - width1)) * (1.0 / width1);
	float c4p = c_out + c_in;
	// 颜色应用
	vec3 ret_col = mix(colour1, colour2, paint_res);
	ret_col = mix(ret_col, colour3, c3p);
	ret_col = mix(ret_col, colour4, c4p);
    COLOR.rgb = ret_col;
}