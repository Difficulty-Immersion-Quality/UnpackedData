#define DISABLE_PROBES

//[Vertex shader]
#include <metal_stdlib>

using namespace metal;

#include "Shaders/Metal/CommonHelpers.shdh"
#include "Shaders/Metal/Global/DS_Globals.shdh"
#include "Shaders/Metal/SkinningHelpers.shdh"

typedef struct
{
	float3 Position SV_POSITION0;
	float4 LocalQTangent NORMAL0;
	float2 TexCoords0 TEXCOORD0;
} VertexInput;

typedef struct
{
	float4 ProjectedPosition [[position, invariant]];
	float3 WorldNormal;
	float3 WorldBinormal;
	float3 WorldTangent;
	float3 WorldOffset;
	float2 TexCoords0;
	float3 LocalPosition;
	float Depth;
	float DepthNormalized;
} VertexOutput;

struct _CB_EngineParams
{
	float4x4 WorldOffsetMatrix;
	uint TransformedVerticesOffset;
	float _FadeOpacity;
};
struct _CB_MaterialConstants
{
	packed_float3 Vector3Parameter_WPO_Strenght;
	float FloatParameter_WPO_Size;
	packed_float3 _WorldExtents;
	float FloatParameter_OutlineFresnelPower;
	packed_float3 Vector3Parameter_SubtractiveBonePosition_Offset;
	float FloatParameter_OutlineIntensity;
	packed_float3 Vector3Parameter_SubtractiveBonePosition;
	float FloatParameter_OpacityFresnelPower;
	packed_float3 Vector3Parameter_GlowColor2;
	float FloatParameter_AlphaBoost;
	packed_float3 Vector3Parameter_GlowColor3;
	float FloatParameter_SubtractiveMaskRadius;
	packed_float3 Vector3Parameter_GlowColor1;
	float FloatParameter_SubtractiveMaskIntensity;
	packed_float3 Vector3Parameter_OutlineColor;
	float FloatParameter_Switch_SubtractiveMask;
	float2 Vector2Parameter_TillingUV;
	float2 Vector2Parameter_SpeedUV;
	float FloatParameter_GlowColorIntensity;
};
static void CalculateMatWorldPositionOffset(constant _CB_MaterialConstants& CB_MaterialConstants,
	constant _PerFrame& PerFrame,
	float3 in_0,
	float4x4 in_1,
	thread float3& out_0)
{
	//LocalPosition {
	//} LocalPosition
	float Local0 = in_0.y;
	float Local1 = (CB_MaterialConstants._WorldExtents.y * CB_MaterialConstants.FloatParameter_WPO_Size);
	float Local2 = (Local0 / Local1);
	float Local3 = (PerFrame.g_CurrentTime + Local2);
	// TriangleWaveNode {
	//TriangleWave
	float Local4 = abs(((fract((Local3 + 0.5f)) * 2.0f) - 1.0f));
	//Smooth TriangleWave
	float Local5 = ((Local4 * Local4) * (3.0f - (2.0f * Local4)));
	// } TriangleWaveNode
	float3 Local6 = (CB_MaterialConstants.Vector3Parameter_WPO_Strenght * Local5);
	//TransformDirectionNode {
	float3 Local7 = (float3x3(in_1[0].xyz, in_1[1].xyz, in_1[2].xyz) * Local6);
	//} TransformDirectionNode
	out_0 = Local7;
}

vertex VertexOutput GustavX_Characters_CHAR_BASE_GM_Fresnel_AlphaTested_Spectre_Shell_ST_FOR_vertexMain(constant _CB_MaterialConstants& CB_MaterialConstants [[buffer(MATERIAL_CONSTANTS_BINDING_POINT)]],
	constant _CB_EngineParams& CB_EngineParams [[buffer(ENGINE_PARAMS_BINDING_POINT)]],
	constant _PerFrame& PerFrame [[buffer(PER_FRAME_BINDING_POINT)]],
	constant _PerCamera& PerCamera [[buffer(PER_CAMERA_BINDING_POINT)]],
	constant const uint8_t* TransformedVertices [[buffer(TRANS_VERT_BINDING_POINT)]],
	uint VertexID [[vertex_id]],
	VertexInput In [[stage_in]])
{
	VertexOutput Out;

	float3 matWorldPositionOffset;
	CalculateMatWorldPositionOffset(CB_MaterialConstants, PerFrame, In.Position.xyz, CB_EngineParams.WorldOffsetMatrix, matWorldPositionOffset);
	float3 localPositionStatic = In.Position;
	if(CB_EngineParams.TransformedVerticesOffset > 0)
	{
		//Skinned vertex
		localPositionStatic = GetSkinnedPosition(VertexID, CB_EngineParams.TransformedVerticesOffset, TransformedVertices);
	}
	//World space offset
	float3 worldOffset = (CB_EngineParams.WorldOffsetMatrix * float4(localPositionStatic, 1.0f)).xyz;

	worldOffset = (worldOffset + matWorldPositionOffset);

	//Projected position
	float4 projectedPosition = (PerCamera.g_OffsetViewProjectionMat * float4(worldOffset, 1.0f));

	//Pass projected position to pixel shader
	Out.ProjectedPosition = projectedPosition;

	float4 transformedQTangent = In.LocalQTangent;
	if(CB_EngineParams.TransformedVerticesOffset > 0)
	{
		//Skinned QTangent
		transformedQTangent = GetSkinnedQTangent(VertexID, CB_EngineParams.TransformedVerticesOffset, TransformedVertices);
	}
	//Compute transformedTangentFrame tangent frame
	float3x3 transformedTangentFrame = GetTangentFrame(transformedQTangent);

	float3 transformedNormal = transformedTangentFrame[2];

	//World space Normal
	float3 worldNormal = (float3x3(CB_EngineParams.WorldOffsetMatrix[0].xyz, CB_EngineParams.WorldOffsetMatrix[1].xyz, CB_EngineParams.WorldOffsetMatrix[2].xyz) * transformedNormal);

	//Normalize World Normal
	float3 worldNormalNormalized = normalize(worldNormal);

	Out.WorldNormal = worldNormalNormalized;

	float3 transformedBinormal = transformedTangentFrame[1];

	//World space Binormal
	float3 worldBinormal = (float3x3(CB_EngineParams.WorldOffsetMatrix[0].xyz, CB_EngineParams.WorldOffsetMatrix[1].xyz, CB_EngineParams.WorldOffsetMatrix[2].xyz) * transformedBinormal);

	//Normalize World Binormal
	float3 worldBinormalNormalized = normalize(worldBinormal);

	Out.WorldBinormal = worldBinormalNormalized;

	float3 transformedTangent = transformedTangentFrame[0];

	//World space Tangent
	float3 worldTangent = (float3x3(CB_EngineParams.WorldOffsetMatrix[0].xyz, CB_EngineParams.WorldOffsetMatrix[1].xyz, CB_EngineParams.WorldOffsetMatrix[2].xyz) * transformedTangent);

	//Normalize World Tangent
	float3 worldTangentNormalized = normalize(worldTangent);

	Out.WorldTangent = worldTangentNormalized;

	//Pass world offset to pixel shader
	Out.WorldOffset = worldOffset;

	Out.TexCoords0 = In.TexCoords0;
	//Pass local position to pixel shader
	Out.LocalPosition = In.Position;

	//View space position
	float3 viewPosition = (float3x3(PerCamera.g_ViewMat[0].xyz, PerCamera.g_ViewMat[1].xyz, PerCamera.g_ViewMat[2].xyz) * worldOffset);

	//Depth
	float depth = viewPosition.z;

	//Pass depth to pixel shader
	Out.Depth = depth;

	//Normalized Depth
	float depthNormalized = (depth / PerCamera.g_FarPlane);

	//Pass normalized depth to pixel shader
	Out.DepthNormalized = depthNormalized;


	return Out;
}


//[Fragment shader]
#include "Shaders/Metal/CommonHelpers.shdh"
#include "Shaders/Metal/Global/DS_Globals.shdh"
#include "Shaders/Metal/Dithering.shdh"
#include "Shaders/Metal/PBR.shdh"
#include "Shaders/Metal/Exposure.shdh"
#include "Shaders/Metal/ImageBasedLightingHelpers.shdh"
#include "Shaders/Metal/ClusteredHelpers.shdh"
#include "Shaders/Metal/AtmosphericHelpers.shdh"
#include "Shaders/Metal/VolumetricFogHelpers.shdh"

typedef struct
{
	float4 ProjectedPosition [[position]];
	float3 WorldNormal;
	float3 WorldBinormal;
	float3 WorldTangent;
	float3 WorldOffset;
	float2 TexCoords0;
	float3 LocalPosition;
	float Depth;
	float DepthNormalized;
} PixelInput;

typedef struct
{
	float4 Color0 [[color(0)]];
} PixelOutput;

static void CalculateMatOpacity(constant _CB_MaterialConstants& CB_MaterialConstants,
	constant _PerFrame& PerFrame,
	float3 in_0,
	float2 in_1,
	float3 in_2,
	float2 in_3,
	thread float& out_0,
	sampler _DefaultWrapSampler,
	texture2d<float> Texture2DParameter_Noise)
{
	//FresnelNode {
	float Local0 = pow((1.0f - saturate(dot(float3(0.0f, 1.0f, 0.0f), in_0))), CB_MaterialConstants.FloatParameter_OutlineFresnelPower);
	//} FresnelNode
	float Local1 = (Local0 * CB_MaterialConstants.FloatParameter_OutlineIntensity);
	//FresnelNode {
	float Local2 = pow((1.0f - saturate(dot(float3(0.0f, 1.0f, 0.0f), in_0))), CB_MaterialConstants.FloatParameter_OpacityFresnelPower);
	//} FresnelNode
	float Local3 = max(Local1, Local2);
	//UVNode {
	//} UVNode
	float2 Local4 = (in_1 * CB_MaterialConstants.Vector2Parameter_TillingUV);
	float2 Local5 = (PerFrame.g_CurrentTime * CB_MaterialConstants.Vector2Parameter_SpeedUV);
	float2 Local6 = (Local4 + Local5);
	//Texture2DNode {
	float4 Local7 = Texture2DParameter_Noise.sample(_DefaultWrapSampler, Local6);
	//[Local7] Get needed components
	float Local8 = Local7.x;
	//} Texture2DNode
	float Local9 = (CB_MaterialConstants.FloatParameter_AlphaBoost * Local8);
	float3 Local10 = (CB_MaterialConstants.Vector3Parameter_SubtractiveBonePosition_Offset + CB_MaterialConstants.Vector3Parameter_SubtractiveBonePosition);
	float3 Local11 = (Local10 + float3(CB_MaterialConstants.FloatParameter_SubtractiveMaskRadius, CB_MaterialConstants.FloatParameter_SubtractiveMaskRadius, CB_MaterialConstants.FloatParameter_SubtractiveMaskRadius));
	float3 Local12 = (Local10 - Local11);
	//DotNode {
	float Local13 = dot(Local12, Local12);
	//} DotNode
	float Local14 = sqrt(Local13);
	//LocalPosition {
	//} LocalPosition
	float3 Local15 = (Local10 - in_2);
	//DotNode {
	float Local16 = dot(Local15, Local15);
	//} DotNode
	float Local17 = sqrt(Local16);
	float Local18 = (Local14 - Local17);
	float Local19 = (Local18 / Local14);
	float Local20 = clamp(Local19, 0.0f, 1.0f);
	float Local21 = (1.0f - Local20);
	float Local22 = pow(Local21, CB_MaterialConstants.FloatParameter_SubtractiveMaskIntensity);
	float Local23 = mix(1.0f, Local22, CB_MaterialConstants.FloatParameter_Switch_SubtractiveMask);
	float Local24 = (Local9 * Local23);
	float Local25 = (Local3 * Local24);
	float Local26;
	if((bool)(PerFrame.g_TAAEnabled))
	{
		float Local27 = InterleavedGradientNoise(in_3.x, in_3.y);
		Local27 = fract((Local27 + s_VanDerCorput8[(int)(fmod(PerFrame.g_FrameID, 8.0f))]));
		Local26 = step(Local27, Local25);
	}
	else
	{
		Local26 = step(0.333f, Local25);
	}
	out_0 = Local26;
}

static void CalculateMatEmissiveColor(constant _CB_MaterialConstants& CB_MaterialConstants,
	float2 in_0,
	float3 in_1,
	thread float3& out_0,
	sampler _DefaultWrapSampler,
	texture2d<float> Texture2DParameter_MSKgradient)
{
	//Texture2DNode {
	float4 Local0 = Texture2DParameter_MSKgradient.sample(_DefaultWrapSampler, in_0);
	//[Local0] Get needed components
	float Local1 = Local0.x;
	//} Texture2DNode
	float Local2 = step(Local1, 0.5f);
	float Local3 = (1.0f - Local2);
	float Local4 = (0.0f + (((Local1 - 0.5f) * (1.0f - 0.0f)) / max(abs((1.0f - 0.5f)), 1E-05f)));
	float3 Local5 = mix(CB_MaterialConstants.Vector3Parameter_GlowColor2, CB_MaterialConstants.Vector3Parameter_GlowColor3, float3(Local4, Local4, Local4));
	float3 Local6 = (Local3 * Local5);
	float Local7 = (0.0f + (((Local1 - 0.0f) * (1.0f - 0.0f)) / max(abs((0.5f - 0.0f)), 1E-05f)));
	float3 Local8 = mix(CB_MaterialConstants.Vector3Parameter_GlowColor1, CB_MaterialConstants.Vector3Parameter_GlowColor2, float3(Local7, Local7, Local7));
	float3 Local9 = (Local2 * Local8);
	float3 Local10 = (Local6 + Local9);
	float3 Local11 = (CB_MaterialConstants.FloatParameter_GlowColorIntensity * Local10);
	//FresnelNode {
	float Local12 = pow((1.0f - saturate(dot(float3(0.0f, 1.0f, 0.0f), in_1))), CB_MaterialConstants.FloatParameter_OutlineFresnelPower);
	//} FresnelNode
	float Local13 = (Local12 * CB_MaterialConstants.FloatParameter_OutlineIntensity);
	float3 Local14 = (Local13 * CB_MaterialConstants.Vector3Parameter_OutlineColor);
	float Local15 = clamp(Local13, 0.0f, 1.0f);
	float3 Local16 = mix(Local11, Local14, float3(Local15, Local15, Local15));
	out_0 = Local16;
}

fragment PixelOutput GustavX_Characters_CHAR_BASE_GM_Fresnel_AlphaTested_Spectre_Shell_ST_FOR_fragmentMain(constant _CB_MaterialConstants& CB_MaterialConstants [[buffer(MATERIAL_CONSTANTS_BINDING_POINT)]],
	constant _CB_EngineParams& CB_EngineParams [[buffer(ENGINE_PARAMS_BINDING_POINT)]],
	constant _PerView& PerView [[buffer(PER_VIEW_BINDING_POINT)]],
	constant _PerFrame& PerFrame [[buffer(PER_FRAME_BINDING_POINT)]],
	constant _PerCamera& PerCamera [[buffer(PER_CAMERA_BINDING_POINT)]],
	constant _PerRT& PerRT [[buffer(PER_RT_BINDING_POINT)]],
	constant _Viewport& Viewport [[buffer(VIEWPORT_BINDING_POINT)]],
	constant const _ForwardLightingConstants& ForwardLightingConstants [[buffer(FORWARD_MATERIALS_BINDING_POINT)]],
	constant const _IBLConstantsBase& IBLConstantsBase [[buffer(IBL_BINDING_POINT)]],
	PixelInput In [[stage_in]],
	sampler _DefaultWrapSampler [[sampler(DEFAULT_WRAP_SAMPLER_BINDING_POINT)]],
	texture2d<float> Texture2DParameter_Noise,
	texture2d<float> Texture2DParameter_MSKgradient,
	sampler TrilinearWrapSampler [[sampler(DEFAULT_TRILINEAR_WRAP_SAMPLER_BINDING_POINT)]],
	EXPOSURE_PARAMS,
	ATMOS_PARAMS,
	FOG_PARAMS,
	IBL_PARAMS)
{
	PixelOutput Out;

	float matOpacity;
	float3x3 NBT_WS = float3x3(float3(In.WorldTangent.x, In.WorldNormal.x, In.WorldBinormal.x), float3(In.WorldTangent.y, In.WorldNormal.y, In.WorldBinormal.y), float3(In.WorldTangent.z, In.WorldNormal.z, In.WorldBinormal.z));

	//Normalized world space view vector
	float3 worldViewNormalized = normalize(-(In.WorldOffset));

	//Calculate tangent space view vector
	float3 tangentView = normalize((NBT_WS * worldViewNormalized));

	CalculateMatOpacity(CB_MaterialConstants, PerFrame, tangentView, In.TexCoords0, In.LocalPosition.xyz, In.ProjectedPosition.xy, matOpacity, _DefaultWrapSampler, Texture2DParameter_Noise);
	matOpacity = (matOpacity * CB_EngineParams._FadeOpacity);

	if ((matOpacity - (0.5f * CB_EngineParams._FadeOpacity)) < 0) discard_fragment();

	float3 matEmissiveColor;
	CalculateMatEmissiveColor(CB_MaterialConstants, In.TexCoords0, tangentView, matEmissiveColor, _DefaultWrapSampler, Texture2DParameter_MSKgradient);
	//Normalize World Normal
	float3 worldNormalNormalized = normalize(In.WorldNormal);

	float3 matBaseColor = float3(0.0f, 0.0f, 0.0f);
	float matMetalMask = 0.0f;
	float matReflectance = 0.5f;
	float matOcclusion = 1.0f;
	float matRoughness = 0.5f;
	float3 FinalColor = float3(0.0f, 0.0f, 0.0f);

	float shadow = 1.0f;
	BSDFData bsdfData;
	FillBSDFDataFromMaterial(matBaseColor, matOcclusion, matReflectance, 0.0f, worldNormalNormalized, matRoughness, float3(1.0f, 0.0f, 0.0f), matMetalMask, 0, 0, 0, 1.0f, 0.0f, false, float3(0.0f, 0.0f, 1.0f), 1.0f, float3(1.0f, 1.0f, 1.0f), 0.0f, 0.4f, nullptr, bsdfData);

	//Exposure
	float svExposure = LoadExposure(Exposure);

	//Evaluate Image Based Lighting Fallback
	float3 iblDiffuseRefl;
	float3 iblSpecularRefl;
	EvaluateDistantIBL(bsdfData, worldViewNormalized, iblDiffuseRefl, iblSpecularRefl, IBL_PARAMS_CONSTRUCT);
	float3 ibl = (iblDiffuseRefl + iblSpecularRefl);

	ibl = (ibl * matOcclusion);

	FinalColor = (FinalColor + (ibl * svExposure));

	//Evaluate Lighting
	float3 worldPos;
	worldPos = (In.WorldOffset + PerCamera.g_CameraWorldPos.xyz);

	float3 sunL;
	float3 extinction;
	float3 inscatter;
	sunL = PerView.g_SunLightColor;
	extinction = float3(1.0f, 1.0f, 1.0f);
	inscatter = float3(0.0f, 0.0f, 0.0f);
	if(PerView.g_ScatteringIntensity > 0.0f)
	{
		EvaluateAtmosphericLighting(TrilinearWrapSampler, PerCamera.g_CameraWorldPos.xyz, worldPos, bsdfData.NormalWS, PerView.g_ScatteringSunDirection, sunL, extinction, inscatter, ATMOS_PARAMS_CONSTRUCT);
		inscatter = (inscatter * (PerView.g_ScatteringIntensity * 10.0f));
		if(PerView.g_CastMoonLight == 0.0f)
		{
			sunL = ((sunL * PerView.g_ScatteringSunColor) * PerView.g_ScatteringSunIntensity);
		}
		else
		{
			sunL = PerView.g_SunLightColor;
		}
	}

	if(PerView.g_CloudsShadowFactor > 0.0f)
	{
		float cloudsShadow;
		cloudsShadow = GetCoverageOffset(TrilinearWrapSampler, In.WorldOffset.xyz, Atmos_PrevCoverage, float3(0.0f, 0.0f, 0.0f), PerView.g_PrevCloudsHeight, PerView.g_PrevCloudsCoverageParams, PerView.g_PrevSunDirection, Atmos_TargCoverage, float3(0.0f, 0.0f, 0.0f), PerView.g_TargCloudsHeight, PerView.g_TargCloudsCoverageParams, PerView.g_TargSunDirection, PerView.g_LerpValue, PerCamera);

		cloudsShadow = SmoothThreshold(cloudsShadow, 0.05f, 0.5f);
		cloudsShadow = (1.0f - saturate((cloudsShadow * PerView.g_CloudsShadowFactor)));
		shadow = (shadow * cloudsShadow);
	}

	if(PerView.g_LocalCoverageScalar > 0.0f)
	{
		float localShadow;
		localShadow = GetCoverageOffset(TrilinearWrapSampler, In.WorldOffset.xyz, PrevLocalCoverageMap, PerView.g_PrevLocalCoverageOffset, PerView.g_PrevLocalCoverageHeight, PerView.g_PrevLocalCoverageParams, PerView.g_PrevSunDirection, TargLocalCoverageMap, PerView.g_TargLocalCoverageOffset, PerView.g_TargLocalCoverageHeight, PerView.g_TargLocalCoverageParams, PerView.g_TargSunDirection, PerView.g_LerpValue, PerCamera);

		localShadow = (1.0f - saturate((localShadow * PerView.g_LocalCoverageScalar)));
		shadow = (shadow * localShadow);
	}

	float3 probeDiffuseRefl;
	float3 probeSpecularRefl;
	float3 diffuseRefl;
	float3 specularRefl;
	EvaluateLighting(bsdfData, In.WorldOffset.xyz, worldViewNormalized, shadow, 0.0f, sunL, false, 0, svExposure, float2(0.0f, 0.0f), probeDiffuseRefl, probeSpecularRefl, diffuseRefl, specularRefl, CLUSTER_PARAMS_CONSTRUCT_NULL, ForwardLightingConstants, PerView, PerCamera);
	float3 directLighting = (diffuseRefl + specularRefl);

	float3 indirectLighting = (probeDiffuseRefl + probeSpecularRefl);

	directLighting = (directLighting * mix(1.0f, matOcclusion, ForwardLightingConstants.g_ForwardAODirectLightInfluence));

	indirectLighting = (indirectLighting * matOcclusion);

	FinalColor = (FinalColor + directLighting);
	FinalColor = (FinalColor + indirectLighting);

	FinalColor = ((FinalColor * extinction) + (inscatter * svExposure));

	FinalColor = (FinalColor + (matEmissiveColor * !PerFrame.g_LightprobeCapture));

	//UV position
	float2 Local0 = (In.ProjectedPosition.xy * float2(PerRT.g_RTInvWidth, PerRT.g_RTInvHeight));

	float svFogDepth = In.DepthNormalized;
	//Fog
	float4 svFog = SampleFog(Local0, svFogDepth, FOG_CONSTRUCT);

	FinalColor = (FinalColor * svFog.www);
	FinalColor = (FinalColor + svFog.xyz);

	Out.Color0 = float4(FinalColor, matOpacity);
	Out.Color0 = max(Out.Color0, 0.0f);

	return Out;
}
