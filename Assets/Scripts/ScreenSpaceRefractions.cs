using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class ScreenSpaceRefractions : MonoBehaviour
{
    [HideInInspector] [SerializeField] private Camera _camera;

    [SerializeField, Range(0, 1)] private float _refectionVisibility = 0;
    [SerializeField, Range(0, 10f)] private float _refractionMagnitude = 0;
    private int _downResFactor = 1;

    private string _globalTextureName = "_GlobalRefractionTex";
    private string _GlobalVisibilty = "_GlobalVisibilty";
    private string _GlobalRefractionMag = "_GlobalRefractionMag";

    private void OnEnable()
    {
        GenerateRT();
        Shader.SetGlobalFloat(_GlobalVisibilty, _refectionVisibility);
        Shader.SetGlobalFloat(_GlobalRefractionMag, _refractionMagnitude);
    }

    private void OnValidate()
    {
        Shader.SetGlobalFloat(_GlobalVisibilty, _refectionVisibility);
        Shader.SetGlobalFloat(_GlobalRefractionMag, _refractionMagnitude);
    }

    void GenerateRT()
    {
        _camera = GetComponent<Camera>();

        // avoid memory leak in editor
        if (_camera.targetTexture != null)
        {
            RenderTexture temp = _camera.targetTexture;
            _camera.targetTexture = null;
            DestroyImmediate(temp);
        }

        // down res the renter texture to give it a fuzzy look
        _camera.targetTexture =
            new RenderTexture(_camera.pixelWidth >> _downResFactor, _camera.pixelHeight >> _downResFactor, 16);
        
        _camera.targetTexture.filterMode = FilterMode.Bilinear;
        
        Shader.SetGlobalTexture(_globalTextureName, _camera.targetTexture);
    }
    
}
