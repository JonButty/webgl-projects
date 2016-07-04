var scene; 
var camera; 
var renderer;
var cubeMesh;
var pointLightMesh;
var pointLight;

function addPointLight () {

  // create a point light
  pointLight = new THREE.PointLight ( 0xFFFFFF );

  // set its position
  pointLight.position.x = 1;
  pointLight.position.y = 0;
  pointLight.position.z = 0;

  // add to the scene
  scene.add ( pointLight );
}

function initCamera () {

  camera = new THREE.PerspectiveCamera ( 75, window.innerWidth/window.innerHeight, 0.1, 1000 );
  
  camera.position.set ( 1,1,1 );
  camera.up = new THREE.Vector3 ( -1, 1,-1 );
  camera.lookAt ( new THREE.Vector3 ( 0, 0,0 ));
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
  renderAxis ();
  renderCube ();
  addPointLight ();
  renderPointLight ();
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

  var geometry = new THREE.BoxGeometry ( 1, 1, 1 );
  var material = new THREE.MeshLambertMaterial ({ color: 0xCC0000 });
  cubeMesh = new THREE.Mesh ( geometry, material );
  scene.add ( cubeMesh );
}

function renderPointLight () {

  var geometry = new THREE.SphereGeometry ( 0.25, 64, 64 );
  var material = new THREE.MeshBasicMaterial ({ color: 0xffffff });
  pointLightMesh = new THREE.Mesh ( geometry, material );

  scene.add ( pointLightMesh );
  pointLightMesh.position.set ( pointLight.position.x, pointLight.position.y, pointLight.position.z );
}

var render = function () {

  requestAnimationFrame ( render );

  cubeMesh.rotation.x += 0.01;
  cubeMesh.rotation.y += 0.01;

  renderer.render ( scene, camera );
};

function start () {

  initScene ();
  render ();
}
start ();