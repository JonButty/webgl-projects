var scene; 
var camera; 
var renderer;

var phongMaterial;

var cubeMesh;
var cubeGeometry;

var pointLightMesh;
var pointLight;

// Light properties
var diffuseColor = new THREE.Vector3 ( 0.5, 0.1, 0.7 );
var specularColor = new THREE.Vector3 ( 1, 1, 1 );
var shineValue = 5;
var lightIntensity = 2;
var attenuation = 0.000001;

function initCamera () {

  camera = new THREE.PerspectiveCamera ( 75, window.innerWidth/window.innerHeight, 0.1, 1000 );
  
  camera.position.set ( 0, 0, 3 );
  camera.up = new THREE.Vector3 ( 0, 1, 0 );
  camera.lookAt ( new THREE.Vector3 ( 0, 0,0 ));
  camera.updateMatrixWorld ( true );

  var controls = new THREE.OrbitControls( camera, renderer.domElement );
  controls.target.set ( 0, 0, 0 );
}

function initThreeJS () {

  scene = new THREE.Scene();
  renderer = new THREE.WebGLRenderer();
  
  // non-fullscreen
  //var canvas = document.getElementById ( 'glCanvas' );
  //var width = canvas.width;
  //var height = canvas.height;
  //renderer.setSize ( width, height );
  renderer.setSize ( window.innerWidth, window.innerHeight );
  document.body.appendChild ( renderer.domElement );
}

function initScene () {

  initThreeJS ();
  initCamera ();
  renderPointLight ();
  renderAxis ();
  renderCube ();
  renderGrid ();
}

function initShader () {

  // Uniforms
  var uniforms = {  
    myColor: { type: "c", value: new THREE.Color( 0xff0000 ) },
    lightPosition: { type: 'v3', value: pointLight.position },
    diffuseColor:  { type: 'v3', value: diffuseColor },
    specularColor:  { type: 'v3', value: specularColor },
    shineValue:  { type: 'f', value: shineValue },
    lightIntensity:  { type: 'f', value: lightIntensity },
    attenuation:  { type: 'f', value: attenuation },
  };

  phongMaterial = new THREE.ShaderMaterial ({  
    uniforms: uniforms,
    vertexShader: document.getElementById ( 'vertexShader' ).textContent,
    fragmentShader: document.getElementById ( 'fragmentShader' ).textContent
  });
}

function renderAxis () {

  var xAxisMaterial = new THREE.LineBasicMaterial ({ color: 0xff0000 });
  var yAxisMaterial = new THREE.LineBasicMaterial ({ color: 0x00ff00 });
  var zAxisMaterial = new THREE.LineBasicMaterial ({ color: 0x0000ff });

  var xAxisGeometry = new THREE.Geometry ();
  xAxisGeometry.vertices.push(new THREE.Vector3 ( 0, 0, 0 ), new THREE.Vector3 ( 1, 0, 0 ));
  var yAxisGeometry = new THREE.Geometry ();
  yAxisGeometry.vertices.push ( new THREE.Vector3 ( 0, 0, 0 ), new THREE.Vector3 ( 0, 1, 0 ));
  var zAxisGeometry = new THREE.Geometry ();
  zAxisGeometry.vertices.push ( new THREE.Vector3 ( 0, 0, 0 ), new THREE.Vector3 ( 0, 0, 1 ));

  var xAxis = new THREE.Line ( xAxisGeometry, xAxisMaterial );
  var yAxis = new THREE.Line ( yAxisGeometry, yAxisMaterial );
  var zAxis = new THREE.Line ( zAxisGeometry, zAxisMaterial );

  scene.add ( xAxis );
  scene.add ( yAxis );
  scene.add ( zAxis );  
}

function renderCube () {

  initShader ();

  cubeGeometry = new THREE.BoxBufferGeometry  ( 1, 1, 1 );
  //cubeGeometry = new THREE.SphereBufferGeometry  ( 1, 64, 64 );
  //cubeGeometry = new THREE.TeapotBufferGeometry  ( 1, 100 );

  var tangents = new Float32Array( cubeGeometry.attributes.position.count * 3 );
  for ( var i = 0; i < tangents.count; i++ ) {
    tangents[ i ] = new THREE.Vector3 ( 1, 0, 0 ); 
  }
  
  cubeGeometry.addAttribute( 'tangent', new THREE.BufferAttribute( tangents, 3 ) );
  //var material = new THREE.MeshPhongMaterial ({ colorDiffuse: diffuseColor, colorSpecular: specularColor, specularCoef: 0.1 });
  cubeMesh = new THREE.Mesh ( cubeGeometry, phongMaterial );
  //cubeMesh = new THREE.Mesh ( cubeGeometry, material );
  scene.add ( cubeMesh );
}

function renderGrid () {

  // each square
  var planeW = 10; // pixels
  var planeH = 10; // pixels 
  var numW = 1; // how many wide (50*50 = 2500 pixels wide)
  var numH = 1; // how many tall (50*50 = 2500 pixels tall)
  var plane = new THREE.Mesh(
      new THREE.PlaneGeometry( planeW*numW, planeH*numH, planeW, planeH ),
      new THREE.MeshBasicMaterial( {
          color: 0xffffff,
          wireframe: true
      } )
  );

  plane.rotation.x = Math.PI/2;
  scene.add(plane);
}

function renderPointLight () {

  // create a point light
  pointLight = new THREE.PointLight ( 0xFFFFFF );

  // set its position
  pointLight.position.x = 1;
  pointLight.position.y = 1;
  pointLight.position.z = 1;

  // add to the scene
  scene.add ( pointLight );

  var geometry = new THREE.SphereGeometry ( 0.25, 64, 64 );
  var material = new THREE.MeshBasicMaterial ({ color: 0xffffff });
  pointLightMesh = new THREE.Mesh ( geometry, material );

  scene.add ( pointLightMesh );
  pointLightMesh.position.set ( pointLight.position.x, pointLight.position.y, pointLight.position.z );
}

var render = function () {

  requestAnimationFrame ( render );

  //cubeMesh.rotateX ( 0.01 );
  cubeMesh.rotateY ( 0.01 );
  cubeMesh.rotateZ ( 0.01 );
  renderer.render ( scene, camera );
};

function start () {

  initScene ();
  render ();
}
start ();