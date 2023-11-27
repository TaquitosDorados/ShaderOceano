// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "OceanShader"
{
	Properties
	{
		_WaveSpeed("Wave Speed", Float) = 1
		_WaveTile("Wave Tile", Float) = 1
		_WaveHeight("Wave Height", Float) = 1
		_Smoothness("Smoothness", Float) = 0.5
		_WaterColor("Water Color", Color) = (0.1370594,0.6472181,0.9433962,1)
		_TopColor("Top Color", Color) = (0.3716981,0.7681991,1,1)
		_EdgeDistance("Edge Distance", Float) = 1
		_EdgePower("Edge Power", Float) = 1
		_NormalMap("Normal Map", 2D) = "white" {}
		_NormalTile("NormalTile", Float) = 1
		_NormalSpeed("Normal Speed", Float) = 1
		_SeaFoam("SeaFoam", 2D) = "white" {}
		_EdgeFoamTile("Edge Foam Tile", Float) = 1
		_Float0("Float 0", Float) = 1
		_FoamMask("Foam Mask", Float) = 2
		_RefractAmount("Refract Amount", Float) = 0.1
		_Depth("Depth", Float) = -4
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		GrabPass{ }
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#include "UnityStandardUtils.cginc"
		#include "UnityCG.cginc"
		#include "Tessellation.cginc"
		#pragma target 4.6
		#if defined(UNITY_STEREO_INSTANCING_ENABLED) || defined(UNITY_STEREO_MULTIVIEW_ENABLED)
		#define ASE_DECLARE_SCREENSPACE_TEXTURE(tex) UNITY_DECLARE_SCREENSPACE_TEXTURE(tex);
		#else
		#define ASE_DECLARE_SCREENSPACE_TEXTURE(tex) UNITY_DECLARE_SCREENSPACE_TEXTURE(tex)
		#endif
		#pragma surface surf Standard keepalpha noshadow vertex:vertexDataFunc tessellate:tessFunction 
		struct Input
		{
			float3 worldPos;
			float4 screenPos;
		};

		uniform float _WaveHeight;
		uniform float _WaveSpeed;
		uniform float _WaveTile;
		uniform sampler2D _NormalMap;
		uniform float _NormalSpeed;
		uniform float _NormalTile;
		uniform float4 _WaterColor;
		uniform float4 _TopColor;
		uniform sampler2D _SeaFoam;
		uniform float _Float0;
		uniform float _FoamMask;
		ASE_DECLARE_SCREENSPACE_TEXTURE( _GrabTexture )
		uniform float _RefractAmount;
		UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
		uniform float4 _CameraDepthTexture_TexelSize;
		uniform float _Depth;
		uniform float _EdgeDistance;
		uniform float _EdgeFoamTile;
		uniform float _EdgePower;
		uniform float _Smoothness;


		float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }

		float snoise( float2 v )
		{
			const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
			float2 i = floor( v + dot( v, C.yy ) );
			float2 x0 = v - i + dot( i, C.xx );
			float2 i1;
			i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
			float4 x12 = x0.xyxy + C.xxzz;
			x12.xy -= i1;
			i = mod2D289( i );
			float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
			float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
			m = m * m;
			m = m * m;
			float3 x = 2.0 * frac( p * C.www ) - 1.0;
			float3 h = abs( x ) - 0.5;
			float3 ox = floor( x + 0.5 );
			float3 a0 = x - ox;
			m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
			float3 g;
			g.x = a0.x * x0.x + h.x * x0.y;
			g.yz = a0.yz * x12.xz + h.yz * x12.yw;
			return 130.0 * dot( m, g );
		}


		inline float4 ASE_ComputeGrabScreenPos( float4 pos )
		{
			#if UNITY_UV_STARTS_AT_TOP
			float scale = -1.0;
			#else
			float scale = 1.0;
			#endif
			float4 o = pos;
			o.y = pos.w * 0.5f;
			o.y = ( pos.y - o.y ) * _ProjectionParams.x * scale + o.y;
			return o;
		}


		float4 tessFunction( appdata_full v0, appdata_full v1, appdata_full v2 )
		{
			return UnityDistanceBasedTess( v0.vertex, v1.vertex, v2.vertex, 0.0,80.0,8.0);
		}

		void vertexDataFunc( inout appdata_full v )
		{
			float temp_output_10_0 = ( _Time.y * _WaveSpeed );
			float2 _WakeDirection = float2(0,1);
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			float4 appendResult12 = (float4(ase_worldPos.x , ase_worldPos.z , 0.0 , 0.0));
			float4 WorldSpaceTile13 = appendResult12;
			float4 WaveTileUV25 = ( ( WorldSpaceTile13 * float4( float2( 0.03,0.1 ), 0.0 , 0.0 ) ) * _WaveTile );
			float2 panner4 = ( temp_output_10_0 * _WakeDirection + WaveTileUV25.xy);
			float simplePerlin2D2 = snoise( panner4 );
			float2 panner28 = ( temp_output_10_0 * _WakeDirection + ( WaveTileUV25 * float4( 0.1,0.1,0,0 ) ).xy);
			float simplePerlin2D27 = snoise( panner28 );
			float WavePattern33 = ( simplePerlin2D2 + simplePerlin2D27 );
			float3 WaveHeight39 = ( ( float3(0,1,0) * _WaveHeight ) * WavePattern33 );
			v.vertex.xyz += WaveHeight39;
			v.vertex.w = 1;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float3 ase_worldPos = i.worldPos;
			float4 appendResult12 = (float4(ase_worldPos.x , ase_worldPos.z , 0.0 , 0.0));
			float4 WorldSpaceTile13 = appendResult12;
			float4 temp_output_66_0 = ( WorldSpaceTile13 * _NormalTile );
			float2 panner70 = ( 1.0 * _Time.y * ( float2( 0,1 ) * _NormalSpeed ) + temp_output_66_0.xy);
			float2 panner71 = ( 1.0 * _Time.y * ( float2( 0,-1 ) * ( _NormalSpeed * 3.0 ) ) + ( temp_output_66_0 * ( _NormalTile * 5.0 ) ).xy);
			float3 Normals80 = BlendNormals( UnpackScaleNormal( tex2D( _NormalMap, panner70 ), 1.0 ) , UnpackScaleNormal( tex2D( _NormalMap, panner71 ), 1.0 ) );
			o.Normal = Normals80;
			float2 panner100 = ( 1.0 * _Time.y * float2( -1,-1 ) + ( WorldSpaceTile13 * _FoamMask ).xy);
			float simplePerlin2D101 = snoise( panner100 );
			float4 clampResult105 = clamp( ( tex2D( _SeaFoam, ( WorldSpaceTile13 * _Float0 ).xy ) * simplePerlin2D101 ) , float4( 0,0,0,0 ) , float4( 1,1,1,0 ) );
			float4 SeaFoam95 = clampResult105;
			float temp_output_10_0 = ( _Time.y * _WaveSpeed );
			float2 _WakeDirection = float2(0,1);
			float4 WaveTileUV25 = ( ( WorldSpaceTile13 * float4( float2( 0.03,0.1 ), 0.0 , 0.0 ) ) * _WaveTile );
			float2 panner4 = ( temp_output_10_0 * _WakeDirection + WaveTileUV25.xy);
			float simplePerlin2D2 = snoise( panner4 );
			float2 panner28 = ( temp_output_10_0 * _WakeDirection + ( WaveTileUV25 * float4( 0.1,0.1,0,0 ) ).xy);
			float simplePerlin2D27 = snoise( panner28 );
			float WavePattern33 = ( simplePerlin2D2 + simplePerlin2D27 );
			float clampResult50 = clamp( WavePattern33 , 0.0 , 1.0 );
			float4 lerpResult48 = lerp( _WaterColor , ( _TopColor + SeaFoam95 ) , clampResult50);
			float4 Albedo51 = lerpResult48;
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_grabScreenPos = ASE_ComputeGrabScreenPos( ase_screenPos );
			float4 ase_grabScreenPosNorm = ase_grabScreenPos / ase_grabScreenPos.w;
			float4 screenColor113 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabTexture,( float3( (ase_grabScreenPosNorm).xy ,  0.0 ) + ( _RefractAmount * Normals80 ) ).xy);
			float4 clampResult114 = clamp( screenColor113 , float4( 0,0,0,0 ) , float4( 1,1,1,0 ) );
			float4 Refraction115 = clampResult114;
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float screenDepth119 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy ));
			float distanceDepth119 = abs( ( screenDepth119 - LinearEyeDepth( ase_screenPosNorm.z ) ) / ( _Depth ) );
			float clampResult120 = clamp( ( 1.0 - distanceDepth119 ) , 0.0 , 1.0 );
			float Depth121 = clampResult120;
			float4 lerpResult122 = lerp( Albedo51 , Refraction115 , Depth121);
			o.Albedo = lerpResult122.rgb;
			float screenDepth54 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy ));
			float distanceDepth54 = abs( ( screenDepth54 - LinearEyeDepth( ase_screenPosNorm.z ) ) / ( _EdgeDistance ) );
			float4 clampResult61 = clamp( ( ( ( 1.0 - distanceDepth54 ) + tex2D( _SeaFoam, ( WorldSpaceTile13 * _EdgeFoamTile ).xy ) ) * _EdgePower ) , float4( 0,0,0,0 ) , float4( 1,1,1,0 ) );
			float4 Edge59 = clampResult61;
			o.Emission = Edge59.rgb;
			o.Smoothness = _Smoothness;
			o.Alpha = 1;
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18934
0;0;1536;803;2573.254;-1843.425;1;True;False
Node;AmplifyShaderEditor.CommentaryNode;14;-2632.778,-606.9021;Inherit;False;754.1024;303.4;World Space UVs;3;11;12;13;;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldPosInputsNode;11;-2582.778,-537.0809;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DynamicAppendNode;12;-2359.544,-555.902;Inherit;True;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.CommentaryNode;34;-2677.988,-280.975;Inherit;False;1081.635;481.1691;Wave Tile;6;15;19;17;25;16;18;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;13;-2111.476,-545.8904;Inherit;False;WorldSpaceTile;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.CommentaryNode;81;-1029.365,663.5027;Inherit;False;2343.782;680.0666;Normal Map;19;65;66;67;63;68;69;72;73;64;44;70;71;74;75;76;77;78;79;80;;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;15;-2627.988,-230.975;Inherit;False;13;WorldSpaceTile;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.Vector2Node;16;-2617.303,-109.4867;Inherit;True;Constant;_WaveStretch;Wave Stretch;2;0;Create;True;0;0;0;False;0;False;0.03,0.1;0.03,0.23;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;19;-2203.263,84.79411;Inherit;False;Property;_WaveTile;Wave Tile;1;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;76;-388.8311,958.6644;Inherit;False;Property;_NormalSpeed;Normal Speed;10;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;65;-974.6578,735.5468;Inherit;False;13;WorldSpaceTile;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;17;-2362.51,-158.8531;Inherit;True;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;67;-979.3652,855.5852;Inherit;False;Property;_NormalTile;NormalTile;9;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;77;-146.4856,940.7391;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;3;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;18;-2059.666,-145.326;Inherit;True;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.Vector2Node;72;-534.8376,805.2783;Inherit;False;Constant;_PanDirection;Pan Direction;10;0;Create;True;0;0;0;False;0;False;0,1;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.CommentaryNode;106;-2822.468,2123.219;Inherit;False;1485.707;569.2202;Sea Foam;11;99;90;98;91;93;100;94;101;104;105;95;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;69;-664.606,1085.475;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;73;-576.0893,1181.369;Inherit;False;Constant;_PanDirection2;Pan Direction 2;10;0;Create;True;0;0;0;False;0;False;0,-1;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;66;-720.459,789.6818;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;90;-2772.468,2175.981;Inherit;False;13;WorldSpaceTile;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;74;-167.4092,801.4794;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;25;-1821.153,-131.1385;Inherit;False;WaveTileUV;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;68;-560.0853,990.9066;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;99;-2752.397,2517.581;Inherit;False;Property;_FoamMask;Foam Mask;14;0;Create;True;0;0;0;False;0;False;2;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;35;-2745.619,264.4871;Inherit;False;1501.823;921.9256;Wave Pattern;13;8;7;31;26;5;10;32;28;4;27;30;2;33;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;75;31.70761,1157.545;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;70;263.1031,713.5027;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;31;-2664.974,956.4127;Inherit;True;25;WaveTileUV;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;98;-2535.223,2458.525;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.CommentaryNode;62;-2825.203,1315.077;Inherit;False;1654.05;782.5864;Edge;13;59;61;58;57;89;56;54;55;84;86;87;85;83;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;91;-2752.785,2284.422;Inherit;False;Property;_Float0;Float 0;13;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;8;-2677.165,851.2798;Inherit;False;Property;_WaveSpeed;Wave Speed;0;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;71;254.9508,1115.017;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;7;-2678.767,726.2969;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;79;164.711,944.3163;Inherit;False;Constant;_NormalStrength;Normal Strength;11;0;Create;True;0;0;0;False;0;False;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;63;-875.166,975.1312;Inherit;True;Property;_NormalMap;Normal Map;8;0;Create;True;0;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.TexturePropertyNode;83;-2793.184,1612.536;Inherit;True;Property;_SeaFoam;SeaFoam;11;0;Create;True;0;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.Vector2Node;5;-2676.334,563.5674;Inherit;False;Constant;_WakeDirection;Wake Direction;0;0;Create;True;0;0;0;False;0;False;0,1;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;93;-2531.698,2184.933;Inherit;True;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SamplerNode;64;476.2609,1008.722;Inherit;True;Property;_WaterMap2;Water Map2;4;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;26;-2695.619,314.4871;Inherit;True;25;WaveTileUV;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.PannerNode;100;-2368.186,2443.669;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;-1,-1;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;10;-2480.077,753.5367;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;32;-2409.552,964.2117;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0.1,0.1,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SamplerNode;44;498.696,804.4773;Inherit;True;Property;_WaterMap;Water Map;4;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;28;-2319.463,624.9324;Inherit;True;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;4;-2365.149,363.8695;Inherit;True;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;101;-2159.533,2434.039;Inherit;True;Simplex2D;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.BlendNormalsNode;78;845.7784,922.455;Inherit;False;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;94;-2242.995,2173.219;Inherit;True;Property;_TextureSample1;Texture Sample 1;12;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NoiseGeneratorNode;27;-2020.21,607.9359;Inherit;True;Simplex2D;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;104;-1883.679,2403.87;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;116;-985.3806,1441.639;Inherit;False;1259.112;487.9049;Refraction;9;107;108;110;109;111;112;113;114;115;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;80;1089.617,940.953;Inherit;False;Normals;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;2;-2065.895,346.873;Inherit;True;Simplex2D;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;30;-1706.418,534.006;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;87;-2768.521,1953.246;Inherit;False;Property;_EdgeFoamTile;Edge Foam Tile;12;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GrabScreenPosition;107;-921.7533,1491.639;Inherit;False;0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;109;-935.3806,1715.579;Inherit;False;Property;_RefractAmount;Refract Amount;15;0;Create;True;0;0;0;False;0;False;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;105;-1723.762,2418.862;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;1,1,1,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;111;-907.2194,1814.144;Inherit;False;80;Normals;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;55;-2585.78,1422.471;Inherit;False;Property;_EdgeDistance;Edge Distance;6;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;129;-1020.502,2034.656;Inherit;False;1086.237;210.9097;Depth;5;118;119;125;120;121;;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;85;-2788.204,1844.805;Inherit;False;13;WorldSpaceTile;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ComponentMaskNode;108;-658.4597,1509.061;Inherit;False;True;True;False;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;53;-495.7038,-877.0858;Inherit;False;1172.581;564.8093;Albedo;8;51;48;50;49;46;45;96;97;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;33;-1468.597,560.3683;Inherit;False;WavePattern;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DepthFade;54;-2374.397,1397.478;Inherit;False;True;False;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;95;-1561.562,2255.604;Inherit;True;SeaFoam;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;110;-670.9758,1742.176;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;86;-2547.434,1853.757;Inherit;True;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;118;-970.5015,2107.645;Inherit;False;Property;_Depth;Depth;16;0;Create;True;0;0;0;False;0;False;-4;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;84;-2283.497,1598.199;Inherit;True;Property;_TextureSample0;Texture Sample 0;12;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;56;-2109.411,1433.216;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DepthFade;119;-800.2448,2084.656;Inherit;False;True;False;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;46;-445.7038,-637.0858;Inherit;False;Property;_TopColor;Top Color;5;0;Create;True;0;0;0;False;0;False;0.3716981,0.7681991,1,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;112;-433.3393,1610.756;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;96;-417.9058,-457.6148;Inherit;False;95;SeaFoam;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;49;-186.7979,-414.4498;Inherit;False;33;WavePattern;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;40;-1601.616,-645.7988;Inherit;False;956.6017;409.2123;Wave Height;6;24;23;36;37;38;39;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;89;-1951.77,1547.908;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;97;-143.5827,-658.7626;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;58;-1897.598,1648.478;Inherit;False;Property;_EdgePower;Edge Power;7;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;125;-527.2369,2094.474;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;36;-1551.616,-420.306;Inherit;False;Property;_WaveHeight;Wave Height;2;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenColorNode;113;-269.9028,1604.986;Inherit;False;Global;_GrabScreen0;Grab Screen 0;16;0;Create;True;0;0;0;False;0;False;Object;-1;False;False;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;45;-441.9037,-827.0858;Inherit;False;Property;_WaterColor;Water Color;4;0;Create;True;0;0;0;False;0;False;0.1370594,0.6472181,0.9433962,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ClampOpNode;50;-0.9973602,-488.8414;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;23;-1537.653,-572.1191;Inherit;False;Constant;_WaveUp;Wave Up;2;0;Create;True;0;0;0;False;0;False;0,1,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;57;-1764.812,1499.026;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;38;-1316.651,-351.9865;Inherit;False;33;WavePattern;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;24;-1353.781,-595.7988;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ClampOpNode;120;-317.3003,2088.366;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;48;141.902,-762.4124;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClampOpNode;114;-98.36655,1614.309;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;1,1,1,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;37;-1091.553,-506.5314;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;121;-159.0647,2112.899;Inherit;False;Depth;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;115;48.93096,1632.954;Inherit;False;Refraction;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;51;412.3974,-763.9523;Inherit;False;Albedo;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClampOpNode;61;-1627.248,1481.344;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;1,1,1,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;128;-641.7385,535.4574;Inherit;False;Constant;_Float2;Float 2;17;0;Create;True;0;0;0;False;0;False;80;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;22;-649.2606,374.366;Inherit;False;Constant;_Tesselation;Tesselation;2;0;Create;True;0;0;0;False;0;False;8;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;59;-1380.606,1476.79;Inherit;False;Edge;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;123;-310.5396,-146.4367;Inherit;False;115;Refraction;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;52;-297.5291,-212.0456;Inherit;False;51;Albedo;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;39;-869.8145,-493.0928;Inherit;False;WaveHeight;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;124;-316.604,-73.66305;Inherit;False;121;Depth;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;127;-640.4384,471.7575;Inherit;False;Constant;_Float1;Float 1;17;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;122;-115.4657,-177.7698;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;41;-336.0938,295.2689;Inherit;False;39;WaveHeight;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;82;-326.1803,23.44865;Inherit;False;80;Normals;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DistanceBasedTessNode;126;-387.1226,412.916;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;42;-335.1492,216.7967;Inherit;False;Property;_Smoothness;Smoothness;3;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;60;-320.9193,135.8381;Inherit;False;59;Edge;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;0,0;Float;False;True;-1;6;ASEMaterialInspector;0;0;Standard;OceanShader;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;False;0;False;Opaque;;Geometry;All;18;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;True;2;15;10;25;False;0.5;False;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;-1;-1;-1;0;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;12;0;11;1
WireConnection;12;1;11;3
WireConnection;13;0;12;0
WireConnection;17;0;15;0
WireConnection;17;1;16;0
WireConnection;77;0;76;0
WireConnection;18;0;17;0
WireConnection;18;1;19;0
WireConnection;69;0;67;0
WireConnection;66;0;65;0
WireConnection;66;1;67;0
WireConnection;74;0;72;0
WireConnection;74;1;76;0
WireConnection;25;0;18;0
WireConnection;68;0;66;0
WireConnection;68;1;69;0
WireConnection;75;0;73;0
WireConnection;75;1;77;0
WireConnection;70;0;66;0
WireConnection;70;2;74;0
WireConnection;98;0;90;0
WireConnection;98;1;99;0
WireConnection;71;0;68;0
WireConnection;71;2;75;0
WireConnection;93;0;90;0
WireConnection;93;1;91;0
WireConnection;64;0;63;0
WireConnection;64;1;71;0
WireConnection;64;5;79;0
WireConnection;100;0;98;0
WireConnection;10;0;7;0
WireConnection;10;1;8;0
WireConnection;32;0;31;0
WireConnection;44;0;63;0
WireConnection;44;1;70;0
WireConnection;44;5;79;0
WireConnection;28;0;32;0
WireConnection;28;2;5;0
WireConnection;28;1;10;0
WireConnection;4;0;26;0
WireConnection;4;2;5;0
WireConnection;4;1;10;0
WireConnection;101;0;100;0
WireConnection;78;0;44;0
WireConnection;78;1;64;0
WireConnection;94;0;83;0
WireConnection;94;1;93;0
WireConnection;27;0;28;0
WireConnection;104;0;94;0
WireConnection;104;1;101;0
WireConnection;80;0;78;0
WireConnection;2;0;4;0
WireConnection;30;0;2;0
WireConnection;30;1;27;0
WireConnection;105;0;104;0
WireConnection;108;0;107;0
WireConnection;33;0;30;0
WireConnection;54;0;55;0
WireConnection;95;0;105;0
WireConnection;110;0;109;0
WireConnection;110;1;111;0
WireConnection;86;0;85;0
WireConnection;86;1;87;0
WireConnection;84;0;83;0
WireConnection;84;1;86;0
WireConnection;56;0;54;0
WireConnection;119;0;118;0
WireConnection;112;0;108;0
WireConnection;112;1;110;0
WireConnection;89;0;56;0
WireConnection;89;1;84;0
WireConnection;97;0;46;0
WireConnection;97;1;96;0
WireConnection;125;0;119;0
WireConnection;113;0;112;0
WireConnection;50;0;49;0
WireConnection;57;0;89;0
WireConnection;57;1;58;0
WireConnection;24;0;23;0
WireConnection;24;1;36;0
WireConnection;120;0;125;0
WireConnection;48;0;45;0
WireConnection;48;1;97;0
WireConnection;48;2;50;0
WireConnection;114;0;113;0
WireConnection;37;0;24;0
WireConnection;37;1;38;0
WireConnection;121;0;120;0
WireConnection;115;0;114;0
WireConnection;51;0;48;0
WireConnection;61;0;57;0
WireConnection;59;0;61;0
WireConnection;39;0;37;0
WireConnection;122;0;52;0
WireConnection;122;1;123;0
WireConnection;122;2;124;0
WireConnection;126;0;22;0
WireConnection;126;1;127;0
WireConnection;126;2;128;0
WireConnection;0;0;122;0
WireConnection;0;1;82;0
WireConnection;0;2;60;0
WireConnection;0;4;42;0
WireConnection;0;11;41;0
WireConnection;0;14;126;0
ASEEND*/
//CHKSM=657F19FA5D95B6D7AF81AB932CC6B8F75C550B72