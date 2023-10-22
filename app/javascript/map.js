console.log("success");

async function initMap() {
  const { Map, InfoWindow } = await google.maps.importLibrary("maps");
  const { Marker, PinElement } = await google.maps.importLibrary("marker");

  let map;

  const coords = document.getElementById("finishers-map");
  const position = {
    lat: parseFloat(coords.getAttribute("data-latitude")),
    lng: parseFloat(coords.getAttribute("data-longitude")),
  };

  map = new Map(document.getElementById("map"), {
    zoom: 11,
    center: position,
    mapId: "DEMO_MAP_ID",
  });

  const finishers = document.querySelectorAll("li.finisher-list-item");

  finishers.forEach((finisher) => {
    const marker = new google.maps.Marker({
      position: {
        lat: parseFloat(finisher.getAttribute("data-latitude")),
        lng: parseFloat(finisher.getAttribute("data-longitude")),
      },
      map: map,
    });
  });
}

// initMap();

window.initMap = initMap;
