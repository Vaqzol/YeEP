// dashboard.js - สำหรับดู "ทุกคัน"

const SUT_LAT = 14.8800;
const SUT_LNG = 102.0250;
let map = null;
let activeMarkers = {}; // เก็บ Marker หลายตัว { "1": markerObj, "4": markerObj }

// ข้อมูลเส้นทาง (ใช้ชุดเดียวกับ app.js)
const busRoutes = [
    {
        id: 'red', color: '#FF4500', 
        stops: [
            { name: "จุดจอด 1 (แดง)", lat: 14.877930, lng: 102.015060 },
            { name: "จุดจอด 2 (แดง)", lat: 14.882377, lng: 102.016474 },
            { name: "จุดจอด 3 (แดง)", lat: 14.890806, lng: 102.017775 },
            { name: "จุดจอด 4 (แดง)", lat: 14.894998, lng: 102.016236 },
            { name: "จุดจอด 5 (แดง)", lat: 14.896540, lng: 102.015388 },
            { name: "จุดจอด 6 (แดง)", lat: 14.897147, lng: 102.014177 },
            { name: "จุดจอด 7 (แดง)", lat: 14.895267, lng: 102.013548 },
            { name: "จุดจอด 8 (แดง)", lat: 14.897580, lng: 102.011027 },
            { name: "จุดจอด 9 (แดง)", lat: 14.898868, lng: 102.012041 },
            { name: "จุดจอด 10 (แดง)", lat: 14.877963, lng: 102.021441 },
            { name: "จุดจอด 11 (แดง)", lat: 14.876805, lng: 102.020205 },
            { name: "จุดจอด 12 (แดง)", lat: 14.876982, lng: 102.017428 },
            { name: "จุดจอด 13 (แดง)", lat: 14.875410, lng: 102.015273 },
            { name: "จุดจอด 14 (แดง)", lat: 14.879688, lng: 102.015492 },
            { name: "จุดจอด 15 (แดง)", lat: 14.881850, lng: 102.014024 },
            { name: "จุดจอด 16 (แดง)", lat: 14.886578, lng: 102.019424 },
            { name: "จุดจอด 17 (แดง)", lat: 14.886173, lng: 102.016967 },
            { name: "จุดจอด 18 (แดง)", lat: 14.896606, lng: 102.012582 },
            { name: "จุดจอด 19 (แดง)", lat: 14.899200, lng: 102.011302 }
        ],
        rawPath: [
            [102.021422, 14.877988], [102.022113, 14.877240], [102.021215, 14.876592], [102.020493, 14.877639], [102.020844, 14.877938],
            [102.021566, 14.877858], [102.022113, 14.877250], [102.016527, 14.873435], [102.014135, 14.876760], [102.016412, 14.878276],
            [102.018746, 14.875022], [102.016412, 14.878294], [102.015283, 14.877518], [102.015034, 14.877962], [102.014575, 14.878590],
            [102.015704, 14.879274], [102.013548, 14.882552], [102.015446, 14.883886], [102.015888, 14.884194], [102.016787, 14.882920],
            [102.016632, 14.882396], [102.016818, 14.882965], [102.015888, 14.884179], [102.019935, 14.886892], [102.017547, 14.885303],
            [102.015764, 14.887716], [102.015779, 14.889170], [102.016585, 14.890189], [102.017686, 14.890774], [102.017485, 14.890714],
            [102.019966, 14.886937], [102.015625, 14.893624], [102.016407, 14.894244], [102.016254, 14.895054], [102.016058, 14.895594],
            [102.015905, 14.896187], [102.015458, 14.896525], [102.014746, 14.896984], [102.014494, 14.896957], [102.014187, 14.897159],
            [102.014370, 14.897350], [102.014641, 14.897293], [102.014722, 14.897014], [102.015475, 14.896519], [102.015898, 14.896160],
            [102.016445, 14.894296], [102.015671, 14.893618], [102.014732, 14.894784], [102.013907, 14.895352], [102.013628, 14.895412],
            [102.012906, 14.895622], [102.013732, 14.895382], [102.013381, 14.894086], [102.013958, 14.893857], [102.015269, 14.894036],
            [102.014412, 14.895023], [102.013732, 14.895412], [102.012875, 14.895701], [102.012421, 14.896629], [102.011710, 14.897994],
            [102.011328, 14.897915], [102.011018, 14.897536], [102.011957, 14.897426], [102.011018, 14.897277], [102.011947, 14.897426],
            [102.011648, 14.897984], [102.012029, 14.898862], [102.010730, 14.899420], [102.011648, 14.898054]
        ]
    },
    {
        id: 'blue', color: '#2563EB', 
        stops: [
            { name: "อาคารขนส่ง (Transportation Center)", lat: 14.877854, lng: 102.021388 },
            { name: "หอดูดาว", lat: 14.874543, lng: 102.027434 },
            { name: "รร.สุรวิวัฒ", lat: 14.874938, lng: 102.029420 },
            { name: "รัตนเวช (Rattanavejjapat Building)", lat: 14.863765, lng: 102.035561 },
            { name: "อาคารความเป็นเลิศ (PDRC)", lat: 14.867228, lng: 102.037254 }
        ],
        rawPath: [
            [102.021383, 14.877852], [102.021773, 14.877742], [102.022135, 14.877217], [102.022573, 14.877521], [102.025496, 14.873325],
            [102.028894, 14.875598], [102.030551, 14.873279], [102.033150, 14.872037], [102.036444, 14.870059], [102.037701, 14.867841],
            [102.037767, 14.864961], [102.037691, 14.862982], [102.034588, 14.863065], [102.034778, 14.863525], [102.035663, 14.863553],
            [102.037215, 14.863636], [102.037206, 14.867197], [102.036949, 14.868154], [102.034588, 14.867602], [102.034292, 14.868504],
            [102.033721, 14.869295], [102.032626, 14.870031], [102.031770, 14.870417], [102.032588, 14.872184], [102.030722, 14.873086],
            [102.029380, 14.874678], [102.028828, 14.875533], [102.025534, 14.873344], [102.022563, 14.877521], [102.022135, 14.877208],
            [102.021783, 14.877760], [102.021364, 14.877852]
        ]
    }
];

window.onload = function() {
    initMap();
    startMonitoring();
};

// Mapping from route color to English display name (used when routeName is non-ASCII)
const routeNameMap = {
    green: 'Green Line',
    purple: 'Purple Line',
    orange: 'Orange Line',
    red: 'Red Line',
    blue: 'Blue Line',
    yellow: 'Yellow Line'
};

function initMap() {
    map = L.map('map').setView([SUT_LAT, SUT_LNG], 14);
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        attribution: '&copy; OpenStreetMap Contributors'
    }).addTo(map);
    drawAllRoutes();
}

function startMonitoring() {
    fetchAllBuses();
    // ดึงข้อมูลใหม่ทุก 3 วินาที
    setInterval(fetchAllBuses, 3000);
}

function fetchAllBuses() {
    fetch('/all-gps') // เรียก API ดึงทุกคัน
        .then(res => res.json())
        .then(allBuses => {
            // allBuses = { "1": {lat:..., lng:...}, "4": {lat:..., lng:...} }
            const count = Object.keys(allBuses).length;
            document.getElementById("status").innerText = `📡 พบรถออนไลน์ ${count} คัน`;

                    for (const [busId, loc] of Object.entries(allBuses)) {
                        updateMarker(busId, loc.lat, loc.lng, loc.displayName, loc.routeColor);
                    }
        });
}

        function updateMarker(busId, lat, lng, displayNameFromServer, routeColor) {
    if (lat === 0 && lng === 0) return;

    // determine color: accept hex or named color
    const colorMap = { green: '#22c55e', purple: '#8b5cf6', orange: '#f97316', red: '#FF4500', blue: '#2563EB', yellow: '#f59e0b' };
    let busColor = '#22c55e';
    if (routeColor) {
        if (routeColor.startsWith('#')) busColor = routeColor;
        else if (colorMap[routeColor]) busColor = colorMap[routeColor];
        else busColor = '#22c55e';
    }

    // Determine display name: prefer server-provided displayName, else map by routeColor, else busId
    let displayName = busId;
    if (displayNameFromServer && displayNameFromServer.trim() !== '') {
        displayName = displayNameFromServer;
    } else if (routeColor && routeNameMap[routeColor]) {
        displayName = routeNameMap[routeColor];
    }

    const customIcon = L.divIcon({
        className: 'bus-marker',
        html: `<div class="bus-circle" 
             style="background: linear-gradient(135deg, ${busColor}, ${busColor}dd);
                 box-shadow: 0 0 0 2px ${busColor}66, 0 6px 14px ${busColor}88;">
             ${displayName}</div>`,
        iconSize: [30, 30], iconAnchor: [15, 15]
    });

    if (activeMarkers[busId]) {
        activeMarkers[busId].setLatLng([lat, lng]);
        activeMarkers[busId].setIcon(customIcon);
        activeMarkers[busId].bindPopup(`<b>${displayName} (${busId})</b>`);
    } else {
        const marker = L.marker([lat, lng], {icon: customIcon}).addTo(map);
        marker.bindPopup(`<b>${displayName} (${busId})</b>`);
        activeMarkers[busId] = marker;
    }
}

function drawAllRoutes() {
    busRoutes.forEach(route => {
        // วาดเส้นทาง
        const latLngs = route.rawPath.map(p => [p[1], p[0]]);
        L.polyline(latLngs, {
            color: route.color, weight: 5, opacity: 0.5,
            lineCap: 'round', lineJoin: 'round'
        }).addTo(map);

        // วาดป้ายจอด
        route.stops.forEach(stop => {
            const stopIcon = L.divIcon({
                className: 'bus-stop-icon',
                html: `<div style="background-color: ${route.color}; width: 100%; height: 100%; border-radius: 50%; display: flex; align-items: center; justify-content: center; border: 2px solid white; box-shadow: 0 2px 4px rgba(0,0,0,0.3);">🚏</div>`,
                iconSize: [24, 24], iconAnchor: [12, 12]
            });
            L.marker([stop.lat, stop.lng], { icon: stopIcon })
                .addTo(map).bindPopup(`<b style="color:${route.color}">${stop.name}</b>`);
        });
    });
}