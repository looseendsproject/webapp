// define callback used by script on _map partial
async function initMap() {
  // import needed libraries
  const { Map } = await google.maps.importLibrary("maps");
  const { Point } = await google.maps.importLibrary("core");
  const { Marker } = await google.maps.importLibrary("marker");

  // there is an element on the page that will contain...
  //...the coordinates of the location the user searches for
  // get that element so we can get the lat and long for...
  //...the map's center
  const coords = document.getElementById("finishers-map");
  const position = {
    lat: parseFloat(coords.getAttribute("data-latitude")),
    lng: parseFloat(coords.getAttribute("data-longitude")),
  };

  // create a new map object
  const map = new Map(document.getElementById("map"), {
    zoom: 12,
    center: position,
    mapId: "DEMO_MAP_ID",
  });

  // there is an element that will house all the finishers...
  //...that matched the search criteria
  // get it so we can access the finishers data
  const finishers = document.querySelectorAll("div.finisher-list-item");

  // create the template for a marker on the map
  const svgMarker = {
    path: "M8 1.314C12.438-3.248 23.534 4.735 8 15-7.534 4.736 3.562-3.248 8 1.314z",
    fillColor: "purple",
    fillOpacity: 0.9,
    strokeColor: "black",
    strokeWeight: 1,
    rotation: 0,
    scale: 1.8,
    labelOrigin: new google.maps.Point(8, 7),
    anchor: new google.maps.Point(8, 0),
  };

  // iterate through each finisher and add a marker...
  //...to the map representing them
  finishers.forEach((finisher, i) => {
    const marker = new Marker({
      position: {
        lat: parseFloat(finisher.getAttribute("data-latitude")),
        lng: parseFloat(finisher.getAttribute("data-longitude")),
      },
      map: map,
      title: finisher.getAttribute("data-name"),
      icon: svgMarker,
      label: {
        text: `${i + 1}`,
        fontSize: "18px",
        fontWeight: "900",
        color: "white",
      },
    });

    // work in progress to make the markers clickable
    marker.addListener("click", () => {
      console.log("marker clicked");
    });
  });
}

// add the initMap function to the window object
window.initMap = initMap;
