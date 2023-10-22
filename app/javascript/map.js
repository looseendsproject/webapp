console.log("success");

async function initMap() {
  const { Map } = await google.maps.importLibrary("maps");
  let map;

  const coords = document.getElementById("breweries");
  const position = {
    lat: parseFloat(coords.getAttribute("data-latitude")),
    lng: parseFloat(coords.getAttribute("data-longitude")),
  };

  map = new Map(document.getElementById("map"), {
    center: position,
    zoom: 11,
  });
}

// initMap();

window.initMap = initMap;
