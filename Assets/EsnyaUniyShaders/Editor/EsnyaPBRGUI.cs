using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEditor;

namespace EsnyaFactory {
    public class EsnyaPBRGUI : ShaderGUI
    {
        public const string TAG_RENDER_TYPE = "RenderType";
        public const string TAG_QUEUE = "Queue";
        public const string PROPERTY_MODE = "_Mode";
        public const string PROPERTY_Z_WRITE = "_ZWrite";

        public const string ALPHATEST_ON = "_ALPHATEST_ON", ALPHABLEND_ON = "_ALPHABLEND_ON";
        public const string SRC_BLEND = "__src", DST_BLEND = "__dst";

        public readonly string[] HiddenPropertyNames = {
            "_Mode",
            "__src", "__dst",
            "_AlphaTest", "_AlphaBlend",
            "_ZWrite",

            "_Color",
            "_EmissionColor",
        };

        public enum RenderType
        {
            Opaque,
            TransparentCutout,
            Fade,
            Transparent,
            // Background,
            // Overlay,
        }

        public enum GlossinessMode
        {
            Roughness,
            Smoothness,
        }

        private string GetRenderTypeValue(RenderType renderType)
        {
            return System.Enum.GetName(typeof(RenderType), renderType);
        }

        private int GetDefaultRenderQueue(RenderType renderType)
        {
            switch (renderType)
            {
                case RenderType.Transparent:
                    return 3000;
                case RenderType.TransparentCutout:
                    return 2500;
                // case RenderType.Background:
                //     return 1000;
                // case RenderType.Overlay:
                //     return 4000;

                case RenderType.Opaque:
                default:
                    return 2000;
            }
        }

        private void RenderTypeProperty(MaterialProperty property)
        {
            property.floatValue = (float)(RenderType)EditorGUILayout.EnumPopup(property.displayName, (RenderType)property.floatValue);
        }

        private void ApplyRenderType(MaterialEditor materialEditor, MaterialProperty property)
        {
            foreach (var target in materialEditor.targets.Select(t => t as Material).Where(t => t != null))
            {
                var prevRenderType = RenderType.Opaque;
                System.Enum.TryParse(target.GetTag(TAG_RENDER_TYPE, true), out prevRenderType);
                var renderType = (RenderType)property.floatValue;

                int.TryParse(target.GetTag(TAG_QUEUE, true, GetDefaultRenderQueue(prevRenderType).ToString()), out int prevQueue);

                target.SetOverrideTag(TAG_RENDER_TYPE, GetRenderTypeValue(renderType));
                target.SetOverrideTag(TAG_QUEUE, (prevQueue - GetDefaultRenderQueue(prevRenderType) + GetDefaultRenderQueue(renderType)).ToString());

                switch (renderType)
                {
                    case RenderType.TransparentCutout:
                        target.EnableKeyword(ALPHATEST_ON);
                        target.DisableKeyword(ALPHABLEND_ON);
                        target.SetFloat(PROPERTY_Z_WRITE, 1);
                        break;
                    case RenderType.Fade:
                    case RenderType.Transparent:
                        target.DisableKeyword(ALPHATEST_ON);
                        target.EnableKeyword(ALPHABLEND_ON);
                        target.SetFloat(PROPERTY_Z_WRITE, 0);
                        break;

                    case RenderType.Opaque:
                    default:
                        target.DisableKeyword(ALPHATEST_ON);
                        target.DisableKeyword(ALPHABLEND_ON);
                        target.SetFloat(PROPERTY_Z_WRITE, 1);
                        break;
                }

                switch (renderType)
                {
                    case RenderType.Fade:
                        target.SetInt(SRC_BLEND, (int)BlendMode.SrcAlpha);
                        target.SetInt(DST_BLEND, (int)BlendMode.OneMinusSrcAlpha);
                        break;

                    case RenderType.Transparent:
                        target.SetInt(SRC_BLEND, (int)BlendMode.One);
                        target.SetInt(DST_BLEND, (int)BlendMode.OneMinusSrcAlpha);
                        break;

                    case RenderType.Opaque:
                    case RenderType.TransparentCutout:
                    default:
                        target.SetInt(SRC_BLEND, (int)BlendMode.One);
                        target.SetInt(DST_BLEND, (int)BlendMode.Zero);
                        break;
                }
            }
        }

        private static void SetKeyword(MaterialEditor materialEditor, string keyword, bool enabled, MaterialProperty property = null)
        {
            foreach (var m in materialEditor.targets.Select(t => t as Material).Where(t => t != null))
            {
                if (property != null) property.floatValue = enabled ? 1 : 0;

                if (enabled) m.EnableKeyword(keyword);
                else m.DisableKeyword(keyword);
            }
        }

        private static MaterialProperty GetProperty(IDictionary<string, MaterialProperty> dict, string name)
        {
            return dict.ContainsKey(name) ? dict[name] : null;
        }

        private static MaterialProperty ShaderPropertyField(MaterialEditor materialEditor, IDictionary<string, MaterialProperty> dict, string name, string label)
        {
            var property = GetProperty(dict, name);
            if (property != null) materialEditor.ShaderProperty(property, label);
            return property;
        }

        private static void Header(string label, bool space = true)
        {
            if (space) EditorGUILayout.Space();
            EditorGUILayout.LabelField(label, EditorStyles.boldLabel);
        }

        private static void ApplyMaskMapKeywords(MaterialEditor materialEditor, IDictionary<string, MaterialProperty> dict, GlossinessMode glossinessMode, bool packed)
        {
            SetKeyword(materialEditor, "_SPECGLOSSMAP", glossinessMode == GlossinessMode.Roughness && !packed, GetProperty(dict, "_SPECGLOSSMAP"));
            SetKeyword(materialEditor, "_METALLICGLOSSMAP", glossinessMode == GlossinessMode.Smoothness && !packed, GetProperty(dict, "_METALLICGLOSSMAP"));
            SetKeyword(materialEditor, "_PACKEDMASK_SPECGLOSSMAP", glossinessMode == GlossinessMode.Roughness && packed, GetProperty(dict, "_PACKEDMASK_SPECGLOSSMAP"));
            SetKeyword(materialEditor, "_PACKEDMASK_METALLICGLOSSMAP", glossinessMode == GlossinessMode.Smoothness && packed, GetProperty(dict, "_PACKEDMASK_METALLICGLOSSMAP"));
        }

        private static void ShaderKeywordToggle(MaterialEditor materialEditor, IDictionary<string, MaterialProperty> dict, string propertyName, string label)
        {
            using var scope = new EditorGUI.ChangeCheckScope();
            var prop = ShaderPropertyField(materialEditor, dict, propertyName, label);
            if (scope.changed)
            {
                SetKeyword(materialEditor, propertyName, prop.floatValue != 0);
            }
        }

        public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] props)
        {
            var material = materialEditor.target as Material;

            var dict = props.ToDictionary(p => p.name);

            using (var scope = new EditorGUI.ChangeCheckScope()) {
                RenderTypeProperty(dict["_Mode"]);
                if (scope.changed)
                {
                    materialEditor.RegisterPropertyChangeUndo($"{dict["_Mode"].displayName} changed");
                    ApplyRenderType(materialEditor, dict["_Mode"]);
                }
            }

            Header("Albedo");
            ShaderPropertyField(materialEditor, dict, "_MainTex", "Albedo");
            ShaderPropertyField(materialEditor, dict, "_Color", "Color");

            if (dict["_Mode"].floatValue == (int)RenderType.TransparentCutout)
            {
                var cutoff = dict["_Cutoff"];
                cutoff.floatValue = EditorGUILayout.Slider("Mask Clip Value", cutoff.floatValue, 0, 1);
            }

            var nonPackedRoughness = GetProperty(dict, "_SPECGLOSSMAP")?.floatValue > 0;
            var nonPackedSmoothness = GetProperty(dict, "_METALLICGLOSSMAP")?.floatValue > 0;
            var packedRoughness = GetProperty(dict, "_PACKEDMASK_SPECGLOSSMAP")?.floatValue > 0;
            var packedSmoothness = GetProperty(dict, "_PACKEDMASK_METALLICGLOSSMAP")?.floatValue > 0;
            var glossinessMode = packedSmoothness || nonPackedSmoothness ? GlossinessMode.Smoothness : GlossinessMode.Roughness;
            var packed = packedRoughness || packedSmoothness;

            Header("Metallic");
            ShaderPropertyField(materialEditor, dict, "_MetallicGlossMap", "Metallic Map");
            ShaderPropertyField(materialEditor, dict, "_Metallic", "Metallic");

            using (var scope = new EditorGUI.ChangeCheckScope())
            {
                packed = EditorGUILayout.Toggle("Packed Mask Mode", packed);
                if (scope.changed) ApplyMaskMapKeywords(materialEditor, dict, glossinessMode, packed);
            }
            EditorGUILayout.HelpBox("If Packed Mask Mode enabled, each channels of Metallic Map used for Metallic (R), Ambient Occlusion (G), Height (B) and Smoothness or Roughness (A)", MessageType.Info);

            Header($"{glossinessMode}");

            using (var scope = new EditorGUI.ChangeCheckScope())
            {
                glossinessMode = (GlossinessMode)EditorGUILayout.EnumPopup("Glossiness Mode", glossinessMode);
                if (scope.changed) ApplyMaskMapKeywords(materialEditor, dict, glossinessMode, packed);
            }

            switch (glossinessMode)
            {
                case GlossinessMode.Roughness:
                    if (!packed) ShaderPropertyField(materialEditor, dict, "_SpecGlossMap", "Roughness Map");
                    ShaderPropertyField(materialEditor, dict, "_Glossiness", "Roughness");
                    ShaderPropertyField(materialEditor, dict, "_RougnessCorrection", "Gamma Correction");
                    break;

                case GlossinessMode.Smoothness:
                    ShaderPropertyField(materialEditor, dict, "_Glossiness", "Smoothness");
                    if (!packed) ShaderPropertyField(materialEditor, dict, "_SmoothnessTextureChannel", "Smoothness Texture Channel");
                    ShaderPropertyField(materialEditor, dict, "_SmoothnessCorrection", "Gamma Correction");
                    break;
            }

            ShaderKeywordToggle(materialEditor, dict, "_GeometricSpecularAA", "Geometric Specular AA");

            Header("Normal");
            ShaderPropertyField(materialEditor, dict, "_NORMALMAP", "Enabled");
            var normalMap = dict.ContainsKey("_NORMALMAP") && dict["_NORMALMAP"].floatValue > 0;
            if (normalMap)
            {
                ShaderPropertyField(materialEditor, dict, "_BumpMap", "Normal Map");
                ShaderPropertyField(materialEditor, dict, "_BumpScale", "Scale");
                ShaderPropertyField(materialEditor, dict, "_NORMALMAP_INVERT_Y", "Invert Y");
            }

            Header("Emission");
            ShaderPropertyField(materialEditor, dict, "_EMISSION", "Enabled");
            var emission = dict.ContainsKey("_EMISSION") && dict["_EMISSION"].floatValue > 0;
            if (emission)
            {
                ShaderPropertyField(materialEditor, dict, "_EmissionMap", "Emission Map");
                ShaderPropertyField(materialEditor, dict, "_EmissionColor", "Color");

                using (var cc = new EditorGUI.ChangeCheckScope()) {
                    material.globalIlluminationFlags = (MaterialGlobalIlluminationFlags)EditorGUILayout.EnumFlagsField("Global Illumination Flags", material.globalIlluminationFlags);

                    if (cc.changed) {
                        foreach (var t in materialEditor.targets) {
                            var m = t as Material;
                            if (m != material) m.globalIlluminationFlags = material.globalIlluminationFlags;
                        }
                    }
                }
            }

            Header("Ambient Occlusion");
            ShaderPropertyField(materialEditor, dict, "_OcclusionMap", "Occlusion Map");
            ShaderPropertyField(materialEditor, dict, "_OcclusionStrength", "Strength");

            Header("Height");
            ShaderPropertyField(materialEditor, dict, "_PARALLAXMAP", "Enabled");
            EditorGUILayout.HelpBox("Parallax Occlusion Mapping. Because of height value is UNSCALED, you should modify scale by object size.", MessageType.Info);
            var parallaxMap = dict.ContainsKey("_PARALLAXMAP") && dict["_PARALLAXMAP"].floatValue > 0;
            if (parallaxMap)
            {
                ShaderPropertyField(materialEditor, dict, "_ParallaxMap", "Height Map");
                ShaderPropertyField(materialEditor, dict, "_Parallax", "Scale");
            }

            ShaderPropertyField(materialEditor, dict, "_DETAIL_MULX2", "Use Detail Maps");
            var detailMulx2 = dict.ContainsKey("_DETAIL_MULX2") && dict["_DETAIL_MULX2"].floatValue > 0;
            if (detailMulx2)
            {
                ShaderPropertyField(materialEditor, dict, "_DetailMask", "Detail Mask");
                ShaderPropertyField(materialEditor, dict, "_DetailAlbedoMap", "Detail Albedo");
                ShaderPropertyField(materialEditor, dict, "_DetailNormalMap", "Normal Map");
                ShaderPropertyField(materialEditor, dict, "_DetailNormalMapScale", "Normal Map Scale");
                ShaderPropertyField(materialEditor, dict, "_UVSetforsecondarytextures", "UV Set for secondary textures");
            }

            if (dict.ContainsKey("_TransmissionColor"))
            {
                ShaderPropertyField(materialEditor, dict, "_TransmissionMap", "Transmission Map");
                ShaderPropertyField(materialEditor, dict, "_TransmissionColor", "Color");
            }

            if (dict.ContainsKey("_Translucency"))
            {
                ShaderPropertyField(materialEditor, dict, "_Translucency", "Strength");
                ShaderPropertyField(materialEditor, dict, "_TranslucencyMap", "Translucency Map");
                ShaderPropertyField(materialEditor, dict, "_TranslucencyColor", "Color");
                ShaderPropertyField(materialEditor, dict, "_TransNormalDistortion", "Normal Distortion");
                ShaderPropertyField(materialEditor, dict, "_TransScattering", "Scaterring Falloff");
                ShaderPropertyField(materialEditor, dict, "_TransDirect", "Direct");
                ShaderPropertyField(materialEditor, dict, "_TransAmbient", "Ambient");
                ShaderPropertyField(materialEditor, dict, "_TransShadow", "Shadow");
            }

            if (dict.ContainsKey("_ChromaticAberration"))
            {
                ShaderPropertyField(materialEditor, dict, "_ChromaticAberration", "Chromatic Aberration");
            }

            Header("Other Options");
            ShaderPropertyField(materialEditor, dict, "_ZWrite", "Z Write");
            ShaderPropertyField(materialEditor, dict, "_CullMode", "Cull Mode");

            materialEditor.LightmapEmissionProperty();
            materialEditor.EnableInstancingField();
            materialEditor.RenderQueueField();
        }
    }
}
