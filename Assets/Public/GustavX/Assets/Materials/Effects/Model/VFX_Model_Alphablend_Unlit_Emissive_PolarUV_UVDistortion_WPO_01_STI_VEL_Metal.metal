#define DISABLE_PROBES

//[Vertex shader]
#include <metal_stdlib>

using namespace metal;

#include "Shaders/Metal/CommonHelpers.shdh"
#include "Shaders/Metal/Global/DS_Globals.shdh"

typedef struct
{
	float2 TexCoords0 TEXCOORD0;
	float4 InstanceDynamicParameter COLOR5;
	float4 LocalQTangent NORMAL0;
	float4 InstanceMatrix1 COLOR1;
	float4 InstanceMatrix2 COLOR2;
	float4 InstanceMatrix3 COLOR3;
	float3 Position SV_POSITION0;
	float4 InstanceMatrix_prev1 COLOR7;
	float4 InstanceMatrix_prev2 COLOR8;
	float4 InstanceMatrix_prev3 COLOR9;
	float4 VertexColor COLOR0;
	float4 InstanceColor COLOR4;
} VertexInput;

typedef struct
{
	float4 ProjectedPosition [[position, invariant]];
	float4 ProjectedPosition_prev;
	float4 VertexColor;
	float4 InstanceColor;
	float2 TexCoords0;
	float4 InstanceDynamicParameter;
	float Depth;
} VertexOutput;

struct _CB_EngineParams
{
	float4x4 WorldOffsetMatrix;
	float4x4 WorldOffsetMatrix_prev;
};
struct _CB_MaterialConstants
{
	float2 Vector2Parameter_UV_Stretch;
	float2 Vector2Parameter_UV_Center;
	float2 Vector2Parameter_DistortionTiling;
	float2 Vector2Parameter_DistortionScrollingSpeed;
	float2 Vector2Parameter_Tiling;
	float2 Vector2Parameter_ScrollingSpeed;
	float2 Vector2Parameter_MaskTiling;
	float2 Vector2Parameter_MaskScrollingSpeed;
	float2 Vector2Parameter_FadeInMiddle_SmoothStep;
	float2 Vector2Parameter_Opacity_BordersMask_SmoothStep;
	float FloatParameter_PolarUVExp;
	float FloatParameter_ToggleInvertUV;
	float FloatParameter_DistortionIntensity;
	float FloatParameter__Use_RGBFromMainTexture;
	float FloatParameter_WPO_Multiply;
	float FloatParameter_MaskIntensity;
	float FloatParameter__Use_DistortionMapOnMaskToo;
	float FloatParameter_MaskFadeOutExp;
	float FloatParameter_Switch_UseFadeInMiddle;
	float FloatParameter_BackgroundExp;
	float FloatParameter_BackgroundIntensity;
	float FloatParameter_Opacity_Power;
	float FloatParameter_OpacityPower_UseDynParam;
	float FloatParameter_Opacity_BordersMask_Switch;
	float FloatParameter_AlphaClip;
	float FloatParameter_Opacity;
	float FloatParameter_DepthDifferenceBlendDistance;
};
static void CalculateMatWorldPositionOffset(constant _CB_MaterialConstants& CB_MaterialConstants,
	constant _PerFrame& PerFrame,
	float2 in_0,
	float4 in_1,
	float3 in_2,
	thread float3& out_0,
	sampler _DefaultWrapSampler,
	texture2d<float> Texture2DParameter_DistortionTexture,
	texture2d<float> Texture2DParameter_MainTexture)
{
	//UVNode {
	//} UVNode
	float2 Local0 = (in_0 * CB_MaterialConstants.Vector2Parameter_UV_Stretch);
	float2 Local1 = (Local0 + CB_MaterialConstants.Vector2Parameter_UV_Center);
	float2 Local2 = (float2(-1.0f, -1.0f) + (((Local1 - 0.0f) * (1.0f - -1.0f)) / max(abs((1.0f - 0.0f)), 1E-05f)));
	float2 Local3 = Local2;
	float Local4 = length(Local3);
	float Local5 = (1.0f - Local4);
	float Local6 = pow(Local5, CB_MaterialConstants.FloatParameter_PolarUVExp);
	float Local7 = (1.0f - Local6);
	float Local8 = Local2.y;
	float Local9 = Local2.x;
	float Local10 = atan2(Local8, Local9);
	float Local11 = (0.0f + (((Local10 - -3.14159f) * (1.0f - 0.0f)) / max(abs((3.14159f - -3.14159f)), 1E-05f)));
	float2 Local12 = float2(Local7, Local11);
	float2 Local13 = Local12.yx;
	float2 Local14 = mix(Local12, Local13, float2(CB_MaterialConstants.FloatParameter_ToggleInvertUV, CB_MaterialConstants.FloatParameter_ToggleInvertUV));
	float2 Local15 = float2(Local4, Local11);
	float2 Local16 = (Local15 * CB_MaterialConstants.Vector2Parameter_DistortionTiling);
	float2 Local17 = (PerFrame.g_CurrentTime * CB_MaterialConstants.Vector2Parameter_DistortionScrollingSpeed);
	float2 Local18 = fract(Local17);
	//DynamicParameterNode {
	//} DynamicParameterNode
	float2 Local19 = (CB_MaterialConstants.Vector2Parameter_DistortionScrollingSpeed * in_1.x);
	float2 Local20 = mix(Local18, Local19, float2(in_1.y, in_1.y));
	float2 Local21 = (Local16 + Local20);
	//Texture2DNode {
	float4 Local22 = Texture2DParameter_DistortionTexture.sample(_DefaultWrapSampler, Local21,  level(0.0f));
	//[Local22] Get needed components
	float Local23 = Local22.x;
	//} Texture2DNode
	float Local24 = (Local23 * CB_MaterialConstants.FloatParameter_DistortionIntensity);
	float2 Local25 = (Local14 + float2(Local24, Local24));
	float2 Local26 = (Local25 * CB_MaterialConstants.Vector2Parameter_Tiling);
	float2 Local27 = (PerFrame.g_CurrentTime * CB_MaterialConstants.Vector2Parameter_ScrollingSpeed);
	float2 Local28 = fract(Local27);
	//DynamicParameterNode {
	//} DynamicParameterNode
	float2 Local29 = (CB_MaterialConstants.Vector2Parameter_ScrollingSpeed * in_1.x);
	float2 Local30 = mix(Local28, Local29, float2(in_1.y, in_1.y));
	float2 Local31 = (Local26 + Local30);
	//Texture2DNode {
	float4 Local32 = Texture2DParameter_MainTexture.sample(_DefaultWrapSampler, Local31,  level(0.0f));
	//[Local32] Get needed components
	float3 Local33 = Local32.xyz;
	float Local34 = Local32.x;
	//} Texture2DNode
	float3 Local35 = mix(float3(Local34, Local34, Local34), Local33, float3(CB_MaterialConstants.FloatParameter__Use_RGBFromMainTexture, CB_MaterialConstants.FloatParameter__Use_RGBFromMainTexture, CB_MaterialConstants.FloatParameter__Use_RGBFromMainTexture));
	float3 Local36 = (Local35 * CB_MaterialConstants.FloatParameter_WPO_Multiply);
	//WorldNormalNode {
	//} WorldNormalNode
	float3 Local37 = (Local36 * in_2);
	out_0 = Local37;
}

static void CalculateMatWorldPositionOffset_prev(constant _CB_MaterialConstants& CB_MaterialConstants,
	constant _PerFrame& PerFrame,
	constant _TemporalConstants& TemporalConstants,
	float2 in_0,
	float4 in_1,
	float3 in_2,
	thread float3& out_0,
	sampler _DefaultWrapSampler,
	texture2d<float> Texture2DParameter_DistortionTexture,
	texture2d<float> Texture2DParameter_MainTexture)
{
	//UVNode {
	//} UVNode
	float2 Local0 = (in_0 * CB_MaterialConstants.Vector2Parameter_UV_Stretch);
	float2 Local1 = (Local0 + CB_MaterialConstants.Vector2Parameter_UV_Center);
	float2 Local2 = (float2(-1.0f, -1.0f) + (((Local1 - 0.0f) * (1.0f - -1.0f)) / max(abs((1.0f - 0.0f)), 1E-05f)));
	float2 Local3 = Local2;
	float Local4 = length(Local3);
	float Local5 = (1.0f - Local4);
	float Local6 = pow(Local5, CB_MaterialConstants.FloatParameter_PolarUVExp);
	float Local7 = (1.0f - Local6);
	float Local8 = Local2.y;
	float Local9 = Local2.x;
	float Local10 = atan2(Local8, Local9);
	float Local11 = (0.0f + (((Local10 - -3.14159f) * (1.0f - 0.0f)) / max(abs((3.14159f - -3.14159f)), 1E-05f)));
	float2 Local12 = float2(Local7, Local11);
	float2 Local13 = Local12.yx;
	float2 Local14 = mix(Local12, Local13, float2(CB_MaterialConstants.FloatParameter_ToggleInvertUV, CB_MaterialConstants.FloatParameter_ToggleInvertUV));
	float2 Local15 = float2(Local4, Local11);
	float2 Local16 = (Local15 * CB_MaterialConstants.Vector2Parameter_DistortionTiling);
	float2 Local17 = (TemporalConstants.g_CurrentTime_prev * CB_MaterialConstants.Vector2Parameter_DistortionScrollingSpeed);
	float2 Local18 = fract(Local17);
	//DynamicParameterNode {
	//} DynamicParameterNode
	float2 Local19 = (CB_MaterialConstants.Vector2Parameter_DistortionScrollingSpeed * in_1.x);
	float2 Local20 = mix(Local18, Local19, float2(in_1.y, in_1.y));
	float2 Local21 = (Local16 + Local20);
	//Texture2DNode {
	float4 Local22 = Texture2DParameter_DistortionTexture.sample(_DefaultWrapSampler, Local21,  level(0.0f));
	//[Local22] Get needed components
	float Local23 = Local22.x;
	//} Texture2DNode
	float Local24 = (Local23 * CB_MaterialConstants.FloatParameter_DistortionIntensity);
	float2 Local25 = (Local14 + float2(Local24, Local24));
	float2 Local26 = (Local25 * CB_MaterialConstants.Vector2Parameter_Tiling);
	float2 Local27 = (TemporalConstants.g_CurrentTime_prev * CB_MaterialConstants.Vector2Parameter_ScrollingSpeed);
	float2 Local28 = fract(Local27);
	//DynamicParameterNode {
	//} DynamicParameterNode
	float2 Local29 = (CB_MaterialConstants.Vector2Parameter_ScrollingSpeed * in_1.x);
	float2 Local30 = mix(Local28, Local29, float2(in_1.y, in_1.y));
	float2 Local31 = (Local26 + Local30);
	//Texture2DNode {
	float4 Local32 = Texture2DParameter_MainTexture.sample(_DefaultWrapSampler, Local31,  level(0.0f));
	//[Local32] Get needed components
	float3 Local33 = Local32.xyz;
	float Local34 = Local32.x;
	//} Texture2DNode
	float3 Local35 = mix(float3(Local34, Local34, Local34), Local33, float3(CB_MaterialConstants.FloatParameter__Use_RGBFromMainTexture, CB_MaterialConstants.FloatParameter__Use_RGBFromMainTexture, CB_MaterialConstants.FloatParameter__Use_RGBFromMainTexture));
	float3 Local36 = (Local35 * CB_MaterialConstants.FloatParameter_WPO_Multiply);
	//WorldNormalNode {
	//} WorldNormalNode
	float3 Local37 = (Local36 * in_2);
	out_0 = Local37;
}

vertex VertexOutput GustavX_Model_VFX_Model_Alphablend_Unlit_Emissive_PolarUV_UVDistortion_WPO_01_STI_VEL_vertexMain(constant _CB_MaterialConstants& CB_MaterialConstants [[buffer(MATERIAL_CONSTANTS_BINDING_POINT)]],
	constant _CB_EngineParams& CB_EngineParams [[buffer(ENGINE_PARAMS_BINDING_POINT)]],
	constant _PerFrame& PerFrame [[buffer(PER_FRAME_BINDING_POINT)]],
	constant _PerCamera& PerCamera [[buffer(PER_CAMERA_BINDING_POINT)]],
	constant _TemporalConstants& TemporalConstants [[buffer(TEMPORAL_CONSTANT_BINDING_POINT)]],
	VertexInput In [[stage_in]],
	sampler _DefaultWrapSampler [[sampler(DEFAULT_WRAP_SAMPLER_BINDING_POINT)]],
	texture2d<float> Texture2DParameter_DistortionTexture,
	texture2d<float> Texture2DParameter_MainTexture)
{
	VertexOutput Out;

	float3 matWorldPositionOffset;
	//Create Instance Dynamic Parameter
	//Compute localTangentFrame tangent frame
	float3x3 localTangentFrame = GetTangentFrame(In.LocalQTangent);

	float3 localNormal = localTangentFrame[2];

	//Create Instance WorldOffset Matrix
	float4x4 noBillboardWorldOffsetMatrix = (CB_EngineParams.WorldOffsetMatrix * float4x4(float4(In.InstanceMatrix1.x, In.InstanceMatrix2.x, In.InstanceMatrix3.x, 0.0f), float4(In.InstanceMatrix1.y, In.InstanceMatrix2.y, In.InstanceMatrix3.y, 0.0f), float4(In.InstanceMatrix1.z, In.InstanceMatrix2.z, In.InstanceMatrix3.z, 0.0f), float4(In.InstanceMatrix1.w, In.InstanceMatrix2.w, In.InstanceMatrix3.w, 1.0f)));

	//World space Normal
	float3 worldNormal = (float3x3(noBillboardWorldOffsetMatrix[0].xyz, noBillboardWorldOffsetMatrix[1].xyz, noBillboardWorldOffsetMatrix[2].xyz) * localNormal);

	//Normalize World Normal
	float3 worldNormalNormalized = normalize(worldNormal);

	CalculateMatWorldPositionOffset(CB_MaterialConstants, PerFrame, In.TexCoords0, In.InstanceDynamicParameter, worldNormalNormalized, matWorldPositionOffset, _DefaultWrapSampler, Texture2DParameter_DistortionTexture, Texture2DParameter_MainTexture);
	float3 localPositionStatic = In.Position;
	//World space offset
	float3 worldOffset = (noBillboardWorldOffsetMatrix * float4(localPositionStatic, 1.0f)).xyz;

	worldOffset = (worldOffset + matWorldPositionOffset);

	//Projected position
	float4 projectedPosition = (PerCamera.g_OffsetViewProjectionMat * float4(worldOffset, 1.0f));

	//Pass projected position to pixel shader
	Out.ProjectedPosition = projectedPosition;

	float3 matWorldPositionOffset_prev;
	//Create Instance Dynamic Parameter
	//Create Instance WorldOffset Matrix
	float4x4 noBillboardWorldOffsetMatrix_prev = (CB_EngineParams.WorldOffsetMatrix_prev * float4x4(float4(In.InstanceMatrix_prev1.x, In.InstanceMatrix_prev2.x, In.InstanceMatrix_prev3.x, 0.0f), float4(In.InstanceMatrix_prev1.y, In.InstanceMatrix_prev2.y, In.InstanceMatrix_prev3.y, 0.0f), float4(In.InstanceMatrix_prev1.z, In.InstanceMatrix_prev2.z, In.InstanceMatrix_prev3.z, 0.0f), float4(In.InstanceMatrix_prev1.w, In.InstanceMatrix_prev2.w, In.InstanceMatrix_prev3.w, 1.0f)));

	//World space Normal_prev
	float3 worldNormal_prev = (float3x3(noBillboardWorldOffsetMatrix_prev[0].xyz, noBillboardWorldOffsetMatrix_prev[1].xyz, noBillboardWorldOffsetMatrix_prev[2].xyz) * localNormal);

	//Normalize World Normal (previous frame)
	float3 worldNormalNormalized_prev = normalize(worldNormal_prev);

	CalculateMatWorldPositionOffset_prev(CB_MaterialConstants, PerFrame, TemporalConstants, In.TexCoords0, In.InstanceDynamicParameter, worldNormalNormalized_prev, matWorldPositionOffset_prev, _DefaultWrapSampler, Texture2DParameter_DistortionTexture, Texture2DParameter_MainTexture);
	float3 localPositionStatic_prev = In.Position;
	//World space offset
	float3 worldOffset_prev = (noBillboardWorldOffsetMatrix_prev * float4(localPositionStatic_prev, 1.0f)).xyz;

	worldOffset_prev = (worldOffset_prev + matWorldPositionOffset_prev);

	//Projected position (previous frame)
	float4 projectedPosition_prev = (TemporalConstants.g_OffsetViewProjectionMat_prev * float4(worldOffset_prev, 1.0f));

	//Pass projected position to pixel shader (previous frame)
	Out.ProjectedPosition_prev = projectedPosition_prev;

	Out.VertexColor = In.VertexColor;
	//Create Instance Color
	Out.InstanceColor = In.InstanceColor;
	Out.TexCoords0 = In.TexCoords0;
	Out.InstanceDynamicParameter = In.InstanceDynamicParameter;
	//View space position
	float3 viewPosition = (float3x3(PerCamera.g_ViewMat[0].xyz, PerCamera.g_ViewMat[1].xyz, PerCamera.g_ViewMat[2].xyz) * worldOffset);

	//Depth
	float depth = viewPosition.z;

	//Pass depth to pixel shader
	Out.Depth = depth;


	return Out;
}


//[Fragment shader]
#include "Shaders/Metal/CommonHelpers.shdh"
#include "Shaders/Metal/Global/DS_Globals.shdh"
#include "Shaders/Metal/Global/DS_ForwardMaterials.shdh"
#include "Shaders/Metal/ViewportHelpers.shdh"

typedef struct
{
	float4 ProjectedPosition [[position]];
	float4 ProjectedPosition_prev;
	float4 VertexColor;
	float4 InstanceColor;
	float2 TexCoords0;
	float4 InstanceDynamicParameter;
	float Depth;
} PixelInput;

typedef struct
{
	float2 Velocity [[color(0)]];
} PixelOutput;

static void CalculateMatOpacity(constant _CB_MaterialConstants& CB_MaterialConstants,
	constant _PerFrame& PerFrame,
	constant _PerCamera& PerCamera,
	float4 in_0,
	float4 in_1,
	float2 in_2,
	float4 in_3,
	float2 in_4,
	float in_5,
	thread float& out_0,
	sampler _DefaultWrapSampler,
	texture2d<float> Texture2DParameter_DistortionTexture,
	texture2d<float> Texture2DParameter_MaskTexture,
	texture2d<float> Texture2DParameter_MainTexture,
	sampler _PointMirrorSampler,
	texture2d<float> _LinearDepth)
{
	float Local0 = (in_0.w * in_1.w);
	float Local1 = clamp(CB_MaterialConstants.FloatParameter_MaskIntensity, 0.0f, 1.0f);
	float Local2 = (1.0f - Local1);
	//UVNode {
	//} UVNode
	float2 Local3 = (in_2 * CB_MaterialConstants.Vector2Parameter_UV_Stretch);
	float2 Local4 = (Local3 + CB_MaterialConstants.Vector2Parameter_UV_Center);
	float2 Local5 = (float2(-1.0f, -1.0f) + (((Local4 - 0.0f) * (1.0f - -1.0f)) / max(abs((1.0f - 0.0f)), 1E-05f)));
	float2 Local6 = Local5;
	float Local7 = length(Local6);
	float Local8 = (1.0f - Local7);
	float Local9 = pow(Local8, CB_MaterialConstants.FloatParameter_PolarUVExp);
	float Local10 = (1.0f - Local9);
	float Local11 = Local5.y;
	float Local12 = Local5.x;
	float Local13 = atan2(Local11, Local12);
	float Local14 = (0.0f + (((Local13 - -3.14159f) * (1.0f - 0.0f)) / max(abs((3.14159f - -3.14159f)), 1E-05f)));
	float2 Local15 = float2(Local10, Local14);
	float2 Local16 = float2(Local7, Local14);
	float2 Local17 = (Local16 * CB_MaterialConstants.Vector2Parameter_DistortionTiling);
	float2 Local18 = (PerFrame.g_CurrentTime * CB_MaterialConstants.Vector2Parameter_DistortionScrollingSpeed);
	float2 Local19 = fract(Local18);
	//DynamicParameterNode {
	//} DynamicParameterNode
	float2 Local20 = (CB_MaterialConstants.Vector2Parameter_DistortionScrollingSpeed * in_3.x);
	float2 Local21 = mix(Local19, Local20, float2(in_3.y, in_3.y));
	float2 Local22 = (Local17 + Local21);
	//Texture2DNode {
	float4 Local23 = Texture2DParameter_DistortionTexture.sample(_DefaultWrapSampler, Local22,  level(0.0f));
	//[Local23] Get needed components
	float Local24 = Local23.x;
	//} Texture2DNode
	float Local25 = (Local24 * CB_MaterialConstants.FloatParameter_DistortionIntensity);
	float2 Local26 = (Local15 + float2(Local25, Local25));
	float2 Local27 = mix(Local15, Local26, float2(CB_MaterialConstants.FloatParameter__Use_DistortionMapOnMaskToo, CB_MaterialConstants.FloatParameter__Use_DistortionMapOnMaskToo));
	float2 Local28 = (Local27 * CB_MaterialConstants.Vector2Parameter_MaskTiling);
	float2 Local29 = (PerFrame.g_CurrentTime * CB_MaterialConstants.Vector2Parameter_MaskScrollingSpeed);
	float2 Local30 = fract(Local29);
	//DynamicParameterNode {
	//} DynamicParameterNode
	float2 Local31 = (CB_MaterialConstants.Vector2Parameter_MaskScrollingSpeed * in_3.x);
	float2 Local32 = mix(Local30, Local31, float2(in_3.y, in_3.y));
	float2 Local33 = (Local28 + Local32);
	//Texture2DNode {
	float4 Local34 = Texture2DParameter_MaskTexture.sample(_DefaultWrapSampler, Local33,  level(0.0f));
	//[Local34] Get needed components
	float Local35 = Local34.x;
	//} Texture2DNode
	float Local36 = (Local2 + Local35);
	float Local37 = clamp(Local36, 0.0f, 1.0f);
	float2 Local38 = Local15.yx;
	float2 Local39 = mix(Local15, Local38, float2(CB_MaterialConstants.FloatParameter_ToggleInvertUV, CB_MaterialConstants.FloatParameter_ToggleInvertUV));
	float2 Local40 = (Local39 + float2(Local25, Local25));
	float2 Local41 = (Local40 * CB_MaterialConstants.Vector2Parameter_Tiling);
	float2 Local42 = (PerFrame.g_CurrentTime * CB_MaterialConstants.Vector2Parameter_ScrollingSpeed);
	float2 Local43 = fract(Local42);
	//DynamicParameterNode {
	//} DynamicParameterNode
	float2 Local44 = (CB_MaterialConstants.Vector2Parameter_ScrollingSpeed * in_3.x);
	float2 Local45 = mix(Local43, Local44, float2(in_3.y, in_3.y));
	float2 Local46 = (Local41 + Local45);
	//Texture2DNode {
	float4 Local47 = Texture2DParameter_MainTexture.sample(_DefaultWrapSampler, Local46,  level(0.0f));
	//[Local47] Get needed components
	float3 Local48 = Local47.xyz;
	float Local49 = Local47.x;
	//} Texture2DNode
	float3 Local50 = mix(float3(Local49, Local49, Local49), Local48, float3(CB_MaterialConstants.FloatParameter__Use_RGBFromMainTexture, CB_MaterialConstants.FloatParameter__Use_RGBFromMainTexture, CB_MaterialConstants.FloatParameter__Use_RGBFromMainTexture));
	float3 Local51 = (Local37 * Local50);
	float Local52 = clamp(Local7, 0.0f, 1.0f);
	float Local53 = (1.0f - Local52);
	float Local54 = pow(Local53, CB_MaterialConstants.FloatParameter_MaskFadeOutExp);
	float Local55 = clamp(Local7, 0.0f, 1.0f);
	float Local56 = CB_MaterialConstants.Vector2Parameter_FadeInMiddle_SmoothStep.x;
	float Local57 = CB_MaterialConstants.Vector2Parameter_FadeInMiddle_SmoothStep.y;
	float Local58 = smoothstep(Local56, Local57, Local55);
	float Local59 = (Local54 * Local58);
	float Local60 = mix(Local54, Local59, CB_MaterialConstants.FloatParameter_Switch_UseFadeInMiddle);
	float3 Local61 = (Local51 * Local60);
	float Local62 = pow(Local53, CB_MaterialConstants.FloatParameter_BackgroundExp);
	float Local63 = smoothstep(0.0f, 1.0f, Local62);
	float Local64 = (Local63 * CB_MaterialConstants.FloatParameter_BackgroundIntensity);
	float3 Local65 = (Local61 + float3(Local64, Local64, Local64));
	float3 Local66 = clamp(Local65, 0.0f, 1.0f);
	float Local67 = mix(CB_MaterialConstants.FloatParameter_Opacity_Power, in_3.z, CB_MaterialConstants.FloatParameter_OpacityPower_UseDynParam);
	float3 Local68 = pow(Local66, float3(Local67, Local67, Local67));
	//UVNode {
	//} UVNode
	// TriangleWaveNode {
	//TriangleWave
	float2 Local69 = abs(((fract((in_2 + float2(0.5f, 0.5f))) * 2.0f) - 1.0f));
	// } TriangleWaveNode
	float Local70 = CB_MaterialConstants.Vector2Parameter_Opacity_BordersMask_SmoothStep.x;
	float Local71 = CB_MaterialConstants.Vector2Parameter_Opacity_BordersMask_SmoothStep.y;
	float2 Local72 = smoothstep(Local70, Local71, Local69);
	float Local73 = Local72.x;
	float Local74 = Local72.y;
	float Local75 = min(Local73, Local74);
	float Local76 = clamp(Local75, 0.0f, 1.0f);
	float3 Local77 = (Local68 * Local76);
	float3 Local78 = mix(Local68, Local77, float3(CB_MaterialConstants.FloatParameter_Opacity_BordersMask_Switch, CB_MaterialConstants.FloatParameter_Opacity_BordersMask_Switch, CB_MaterialConstants.FloatParameter_Opacity_BordersMask_Switch));
	if (any((Local78 - CB_MaterialConstants.FloatParameter_AlphaClip) < 0)) discard_fragment();
	float3 Local79 = (Local78 * CB_MaterialConstants.FloatParameter_Opacity);
	float3 Local80 = clamp(Local79, 0.0f, 1.0f);
	//DepthDifferenceBlend
	float Local81 = (_LinearDepth.sample(_PointMirrorSampler, in_4).x * PerCamera.g_FarPlane);
	float Local82 = (Local81 - in_5);
	float Local83 = Local82;
	float Local84 = saturate((Local83 / max(CB_MaterialConstants.FloatParameter_DepthDifferenceBlendDistance, 0.0001f)));
	//~DepthDifferenceBlend

	float3 Local85 = (Local80 * Local84);
	float3 Local86 = (Local0 * Local85);
	out_0 = Local86.x;
}

fragment PixelOutput GustavX_Model_VFX_Model_Alphablend_Unlit_Emissive_PolarUV_UVDistortion_WPO_01_STI_VEL_fragmentMain(constant _CB_MaterialConstants& CB_MaterialConstants [[buffer(MATERIAL_CONSTANTS_BINDING_POINT)]],
	constant _PerFrame& PerFrame [[buffer(PER_FRAME_BINDING_POINT)]],
	constant _PerCamera& PerCamera [[buffer(PER_CAMERA_BINDING_POINT)]],
	constant _PerRT& PerRT [[buffer(PER_RT_BINDING_POINT)]],
	constant _TemporalConstants& TemporalConstants [[buffer(TEMPORAL_CONSTANT_BINDING_POINT)]],
	constant _Viewport& Viewport [[buffer(VIEWPORT_BINDING_POINT)]],
	PixelInput In [[stage_in]],
	sampler _DefaultWrapSampler [[sampler(DEFAULT_WRAP_SAMPLER_BINDING_POINT)]],
	texture2d<float> Texture2DParameter_DistortionTexture,
	texture2d<float> Texture2DParameter_MaskTexture,
	texture2d<float> Texture2DParameter_MainTexture,
	sampler _PointMirrorSampler [[sampler(DEFAULT_POINT_MIRROR_SAMPLER_BINDING_POINT)]],
	texture2d<float> _LinearDepth [[texture(LINEARDEPTH_TEXTURE_BINDING_POINT)]])
{
	PixelOutput Out;

	float matOpacity;
	//UV position
	float2 Local0 = (In.ProjectedPosition.xy * float2(PerRT.g_RTInvWidth, PerRT.g_RTInvHeight));

	CalculateMatOpacity(CB_MaterialConstants, PerFrame, PerCamera, In.VertexColor, In.InstanceColor, In.TexCoords0, In.InstanceDynamicParameter, Local0, In.Depth, matOpacity, _DefaultWrapSampler, Texture2DParameter_DistortionTexture, Texture2DParameter_MaskTexture, Texture2DParameter_MainTexture, _PointMirrorSampler, _LinearDepth);
	if ((matOpacity - 0.5f) < 0) discard_fragment();

	//Current screen pos:
	float2 currentScreenPos = (In.ProjectedPosition.xy + float2(TemporalConstants.g_Jitter.x, -(TemporalConstants.g_Jitter.y)));

	//Previous screen pos:
	float2 previousUV = (((In.ProjectedPosition_prev.xy / In.ProjectedPosition_prev.w) * float2(0.5f, -0.5f)) + float2(0.5f, 0.5f));
	previousUV = ConvertTexCoordsVPtoRT(previousUV, Viewport);
	float2 previousScreenPos = (previousUV * float2(PerRT.g_RTWidth, PerRT.g_RTHeight));
	previousScreenPos = (previousScreenPos + float2(TemporalConstants.g_PreviousJitter.x, -(TemporalConstants.g_PreviousJitter.y)));

	Out.Velocity = (currentScreenPos - previousScreenPos);

	return Out;
}
