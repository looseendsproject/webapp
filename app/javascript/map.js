console.log("success");

async function initMap() {
  const { Map } = await google.maps.importLibrary("maps");
  let map;

  map = new Map(document.getElementById("map"), {
    center: { lat: -34.397, lng: 150.644 },
    zoom: 11,
  });
}

// initMap();

window.initMap = initMap;
