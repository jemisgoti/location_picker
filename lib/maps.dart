import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location_picker/autocomplate.dart';
import 'package:location_picker/locationData.dart';
import 'package:location_picker/locationResult.dart';
import 'package:location_picker/placeDeatails.dart';
import 'package:location_picker/rich_suggestion.dart';
import 'package:location_picker/search_input.dart';

class LocationPicker extends StatefulWidget {
  LatLng initialPosition;
  String apiKey;
  double initialZoom;
  bool setAddresToDefaultLatLng;
  bool isBackButtonVisible;
  String hintText;
  BuildContext context;
  Color? primaryColor, secondaryColor, surfaceColor, appbarColor;

  /// True if the map should show a compass when rotated.
  final bool compassEnabled;

  /// True if the map should show a toolbar when you interact with the map. Android only.
  final bool mapToolbarEnabled;

  /// Geographical bounding box for the camera target.
  final CameraTargetBounds cameraTargetBounds;

  /// Type of map tiles to be rendered.
  final MapType mapType;

  /// Preferred bounds for the camera zoom level.
  ///
  /// Actual bounds depend on map data and device.
  final MinMaxZoomPreference minMaxZoomPreference;

  /// True if the map view should respond to rotate gestures.
  final bool rotateGesturesEnabled;

  /// True if the map view should respond to scroll gestures.
  final bool scrollGesturesEnabled;

  /// True if the map view should show zoom controls. This includes two buttons
  /// to zoom in and zoom out. The default value is to show zoom controls.
  ///
  /// This is only supported on Android. And this field is silently ignored on iOS.
  final bool zoomControlsEnabled;

  /// True if the map view should respond to zoom gestures.
  final bool zoomGesturesEnabled;

  /// True if the map view should be in lite mode. Android only.
  ///
  /// See https://developers.google.com/maps/documentation/android-sdk/lite#overview_of_lite_mode for more details.
  final bool liteModeEnabled;

  /// True if the map view should respond to tilt gestures.
  final bool tiltGesturesEnabled;

  /// Padding to be set on map. See https://developers.google.com/maps/documentation/android-sdk/map#map_padding for more details.
  final EdgeInsets padding;

  // /// Markers to be placed on the map.
  // final Set<Marker> markers;

  // /// Polygons to be placed on the map.
  // final Set<Polygon> polygons;

  // /// Polylines to be placed on the map.
  // final Set<Polyline> polylines;

  // /// Circles to be placed on the map.
  // final Set<Circle> circles;

  final bool myLocationEnabled;

  /// Enables or disables the my-location button.
  ///
  /// The my-location button causes the camera to move such that the user's
  /// location is in the center of the map. If the button is enabled, it is
  /// only shown when the my-location layer is enabled.
  ///
  /// By default, the my-location button is enabled (and hence shown when the
  /// my-location layer is enabled).
  ///
  /// See also:
  ///   * [myLocationEnabled] parameter.
  final bool myLocationButtonEnabled;

  /// Enables or disables the indoor view from the map
  final bool indoorViewEnabled;

  /// Enables or disables the traffic layer of the map
  final bool trafficEnabled;

  /// Enables or disables showing 3D buildings where available
  final bool buildingsEnabled;
  LocationPicker(
      {this.initialPosition =
          const LatLng(37.42796133580664, -122.085749655962),
      this.initialZoom = 14,
      required this.context,
      this.setAddresToDefaultLatLng = false,
      this.isBackButtonVisible = true,
      this.hintText = "Search here..",
      this.appbarColor,
      this.primaryColor,
      this.secondaryColor,
      this.surfaceColor,
      Key? key,
      this.compassEnabled = true,
      this.mapToolbarEnabled = true,
      this.cameraTargetBounds = CameraTargetBounds.unbounded,
      this.mapType = MapType.normal,
      this.minMaxZoomPreference = MinMaxZoomPreference.unbounded,
      this.rotateGesturesEnabled = true,
      this.scrollGesturesEnabled = true,
      this.zoomControlsEnabled = true,
      this.zoomGesturesEnabled = true,
      this.liteModeEnabled = false,
      this.tiltGesturesEnabled = true,
      this.myLocationEnabled = false,
      this.myLocationButtonEnabled = true,

      /// If no padding is specified default padding will be 0.
      this.padding = const EdgeInsets.all(0),
      this.indoorViewEnabled = false,
      this.trafficEnabled = false,
      this.buildingsEnabled = true,
      // this.markers = const <Marker>{},
      // this.polygons = const <Polygon>{},
      // this.polylines = const <Polyline>{},
      // this.circles = const <Circle>{},
      // this.tileOverlays = const <TileOverlay>{},
      required this.apiKey});
  @override
  State<LocationPicker> createState() => LocationPickerState();
}

class LocationPickerState extends State<LocationPicker> {
  Completer<GoogleMapController> _controller = Completer();

  TextEditingController search = TextEditingController();
  LatLng? lastPostion;
  LocationData? data;
  LatLng? selectedPostion;
  LocationResult? selecteData;
  getAddress(LatLng location) async {
    setState(() {
      selecteData = null;
    });
    String url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=${location.latitude},${location.longitude}'
        '&key=${widget.apiKey} ';
    Response response;
    var dio = Dio();
    response = await dio.get(url);
    print(response.data.toString());
// Optionally the request above could also be done as

    print(response.data.toString());

    if (response.statusCode == 200) {
      data = LocationData.fromJson(response.data);
      print(data!.results!.first.formattedAddress);
      setState(() {});
    } else {
      print("server error:" + response.statusCode.toString());
    }
  }

  Color? primaryColor, secondaryColor, surfaceColor, appbarColor;
  bool isSearching = false;
  @override
  void initState() {
    // TODO: implement initState

    setState(() {
      primaryColor = widget.primaryColor != null
          ? widget.primaryColor
          : Theme.of(context).primaryColor;
      secondaryColor = widget.secondaryColor != null
          ? widget.secondaryColor
          : Theme.of(context).colorScheme.secondary;
      surfaceColor = widget.surfaceColor != null
          ? widget.surfaceColor
          : Theme.of(context).scaffoldBackgroundColor;
      appbarColor = widget.appbarColor != null
          ? widget.primaryColor
          : Theme.of(context).appBarTheme.backgroundColor;
      selectedPostion = widget.initialPosition;
      if (widget.setAddresToDefaultLatLng) {
        getAddress(widget.initialPosition);
      }
    });
    super.initState();
  }

  LocationResult? locationResult;

  /// Overlay to display autocomplete suggestions
  OverlayEntry? overlayEntry;

  // List<NearbyPlace> nearbyPlaces = [];

  /// Session token required for autocomplete API call

  var appBarKey = GlobalKey();

  var searchInputKey = GlobalKey<SearchInputState>();

  bool hasSearchTerm = false;

  /// Hides the autocomplete overlay
  void clearOverlay() {
    if (overlayEntry != null) {
      overlayEntry!.remove();
      overlayEntry = null;
    }
  }

  /// Begins the search process by displaying a "wait" overlay then
  /// proceeds to fetch the autocomplete list. The bottom "dialog"
  /// is hidden so as to give more room and better experience for the
  /// autocomplete list overlay.
  void searchPlace(String place) {
    if (context == null) return;

    clearOverlay();

    setState(() => hasSearchTerm = place.length > 0);

    if (place.length < 1) return;

    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    Size size = renderBox.size;

    final RenderBox? appBarBox =
        appBarKey.currentContext!.findRenderObject() as RenderBox?;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: appBarBox!.size.height,
        width: size.width,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Material(
            elevation: 1,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              child: Row(
                children: <Widget>[
                  SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(strokeWidth: 3),
                  ),
                  SizedBox(width: 24),
                  Expanded(
                    child: Text(
                      'Finding place...',
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context)!.insert(overlayEntry!);

    autoCompleteSearch(place);
  }

  /// Fetches the place autocomplete list with the query [place].
  void autoCompleteSearch(String place) async {
    place = place.replaceAll(" ", "+");

    // final countries = widget.countries;

    // // Currently, you can use components to filter by up to 5 countries. from https://developers.google.com/places/web-service/autocomplete
    // String regionParam = countries?.isNotEmpty == true
    //     ? "&components=country:${countries!.sublist(0, min(countries.length, 5)).join('|country:')}"
    //     : "";

    var url = "https://maps.googleapis.com/maps/api/place/autocomplete/json?" +
        "key=${widget.apiKey}&" +
        "input={$place}";
    // '$regionParam&sessiontoken=$sessionToken&" +
    // "language=${widget.language}";

    // if (locationResult != null) {
    //   endpoint += "&location=${locationResult!.latLng!.latitude}," +
    //       "${locationResult!.latLng!.longitude}";
    // }

    Response response;
    var dio = Dio();
    response = await dio.get(url);
    print(response.data.toString());
// Optionally the request above could also be done as

    print(response.data.toString());

    if (response.statusCode == 200) {
      var data = AutoComplete.fromJson(response.data);

      var predictions = data.predictions;

      List<RichSuggestion> suggestions = [];

      if (predictions!.isEmpty) {
        AutoCompleteItem aci = AutoCompleteItem();
        aci.text = 'No result found';
        aci.offset = 0;
        aci.length = 0;

        suggestions.add(RichSuggestion(aci, () {}));
      } else {
        for (var t in predictions) {
          AutoCompleteItem aci = AutoCompleteItem();

          aci.id = t.placeId;
          aci.text = t.description;
          aci.offset = t.matchedSubstrings!.first.length;
          aci.length = t.matchedSubstrings!.first.length;

          suggestions.add(RichSuggestion(aci, () {
            clearOverlay();
            decodeAndSelectPlace(aci.id);
          }));
        }
      }

      displayAutoCompleteSuggestions(suggestions);
    } else {
      print("server error:" + response.statusCode.toString());
    }
  }

  /// To navigate to the selected place from the autocomplete list to the map,
  /// the lat,lng is required. This method fetches the lat,lng of the place and
  /// proceeds to moving the map to that location.
  void decodeAndSelectPlace(String? placeId) async {
    clearOverlay();

    final url =
        "https://maps.googleapis.com/maps/api/place/details/json?key=${widget.apiKey}" +
            "&placeid=$placeId";
    // '&language=${widget.language}';

    Response response;
    var dio = Dio();
    response = await dio.get(url);
    print(response.data.toString());
// Optionally the request above could also be done as

    print(response.data.toString());

    if (response.statusCode == 200) {
      var data = PlaceDetails.fromJson(response.data);
      FocusScopeNode currentFocus = FocusScope.of(context);

      if (!currentFocus.hasPrimaryFocus) {
        clearOverlay();
        currentFocus.unfocus();
      }
      selecteData = LocationResult(
          address: data.result!.formattedAddress,
          allData: data,
          placeId: data.result!.placeId,
          latLng: LatLng(data.result!.geometry!.location!.lat!,
              data.result!.geometry!.location!.lng!));
      setState(() {});
    } else {
      print("server error:" + response.statusCode.toString());
    }
  }

  /// Display autocomplete suggestions with the overlay.
  void displayAutoCompleteSuggestions(List<RichSuggestion> suggestions) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    Size size = renderBox.size;

    final RenderBox? appBarBox =
        appBarKey.currentContext!.findRenderObject() as RenderBox?;

    clearOverlay();

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        top: appBarBox!.size.height,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Material(
            elevation: 1,
            color: surfaceColor,
            child: Column(
              children: suggestions,
            ),
          ),
        ),
      ),
    );

    Overlay.of(context)!.insert(overlayEntry!);
  }

  /// Utility function to get clean readable name of a location. First checks
  /// for a human-readable name from the nearby list. This helps in the cases
  /// that the user selects from the nearby list (and expects to see that as a
  /// result, instead of road name). If no name is found from the nearby list,
  /// then the road name returned is used instead.
//  String getLocationName() {
//    if (locationResult == null) {
//      return "Unnamed location";
//    }
//
//    for (NearbyPlace np in nearbyPlaces) {
//      if (np.latLng == locationResult.latLng) {
//        locationResult.name = np.name;
//        return np.name;
//      }
//    }
//
//    return "${locationResult.name}, ${locationResult.locality}";
//  }

  /// Fetches and updates the nearby places to the provided lat,lng
  ///
  ///
  ///
  @override
  void dispose() {
    // TODO: implement dispose
    clearOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        key: appBarKey,
        brightness: Brightness.dark,
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: SearchInput(
          (input) => searchPlace(input),
          key: searchInputKey,
          hintText: widget.hintText,
          boxDecoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5), color: surfaceColor),
        ),
        automaticallyImplyLeading: widget.isBackButtonVisible,
        leading: widget.isBackButtonVisible
            ? IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                ),
                onPressed: () {
                  clearOverlay();
                  Navigator.pop(context);
                },
              )
            : null,
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                GoogleMap(
                  mapType: MapType.hybrid,
                  initialCameraPosition: CameraPosition(
                    target: widget.initialPosition,
                    zoom: widget.initialZoom,
                  ),
                  onTap: (value) {
                    goToThePosition(value);
                  },
                  buildingsEnabled: widget.buildingsEnabled,
                  cameraTargetBounds: widget.cameraTargetBounds,
                  compassEnabled: widget.compassEnabled,
                  indoorViewEnabled: widget.indoorViewEnabled,
                  liteModeEnabled: widget.liteModeEnabled,
                  key: widget.key,
                  mapToolbarEnabled: widget.mapToolbarEnabled,
                  minMaxZoomPreference: widget.minMaxZoomPreference,
                  myLocationButtonEnabled: widget.myLocationButtonEnabled,
                  rotateGesturesEnabled: widget.rotateGesturesEnabled,
                  zoomControlsEnabled: widget.zoomControlsEnabled,
                  zoomGesturesEnabled: widget.zoomGesturesEnabled,
                  trafficEnabled: widget.trafficEnabled,
                  myLocationEnabled: widget.myLocationEnabled,
                  padding: widget.padding,
                  scrollGesturesEnabled: widget.scrollGesturesEnabled,
                  tiltGesturesEnabled: widget.tiltGesturesEnabled,

                  onCameraMove: (CameraPosition position) {
                    // print(position.target);
                    lastPostion = position.target;
                    // print("initial" + widget.initialPosition.toString());
                  },
                  onCameraIdle: () async {
                    // print("onCameraIdle#_lastMapPosition = $_lastMapPosition");
                    // LocationProvider.of(context, listen: false)

                    //     .setLastIdleLocation(_lastMapPosition);
                    selectedPostion = lastPostion;
                    getAddress(selectedPostion!);
                    print(selectedPostion);
                    print("initial " + widget.initialPosition.toString());
                  },
                  onCameraMoveStarted: () {
                    // print(
                    //     "onCameraMoveStarted#_lastMapPosition = $_lastMapPosition");
                  },
                  // markers: Set<Marker>.of(
                  //   <Marker>[
                  //     Marker(
                  //         draggable: true,
                  //         markerId: MarkerId("1"),
                  //         position: LatLng(widget.initialPosition.latitude,
                  //             widget.initialPosition.longitude),
                  //         icon: BitmapDescriptor.defaultMarker,
                  //         infoWindow: const InfoWindow(
                  //           title: 'Select location',
                  //         ),
                  //         onDragEnd: ((newPosition) {
                  //           print(newPosition.latitude);
                  //           print(newPosition.longitude);
                  //         }))
                  //   ],
                  // ),
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                  },
                ),
                IgnorePointer(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.place,
                          size: 56,
                          color: primaryColor,
                        ),
                        Container(
                          decoration: ShapeDecoration(
                            shadows: [
                              BoxShadow(
                                blurRadius: 4,
                                color: primaryColor!,
                              ),
                            ],
                            shape: CircleBorder(
                              side: BorderSide(
                                width: 4,
                                color: Colors.transparent,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 56),
                      ],
                    ),
                  ),
                ),
                KeyboardVisibilityBuilder(
                    builder: (context, isKeyboardVisible) {
                  return isKeyboardVisible
                      ? SizedBox.shrink()
                      : Align(
                          alignment: isSearching
                              ? Alignment.topCenter
                              : Alignment.bottomCenter,
                          child: selecteData != null
                              ? Container(
                                  padding: EdgeInsets.all(12),
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                    child: ListTile(
                                      onTap: () {
                                        Navigator.pop(context, selecteData);
                                      },
                                      leading: Container(
                                          padding: EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(100),
                                            color: primaryColor,
                                          ),
                                          child: Icon(
                                            Icons.location_on,
                                            color: surfaceColor,
                                          )),
                                      title: Text(
                                        selecteData!.address!,
                                      ),
                                      trailing: IconButton(
                                          onPressed: () {
                                            Navigator.pop(context, selecteData);
                                          },
                                          icon: Icon(Icons.check,
                                              color: primaryColor)),
                                    ),
                                  ),
                                )
                              : Container(
                                  height: data == null ? 120 : 250,
                                  padding: EdgeInsets.all(16.0),
                                  child: Card(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      child: Padding(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 14),
                                        child: data == null
                                            ? Center(
                                                child: Text(
                                                    "Drag marker pin or seaarch to find location around you!"),
                                              )
                                            : ListView.builder(
                                                shrinkWrap: true,
                                                itemCount:
                                                    data!.results!.length > 3
                                                        ? 3
                                                        : data!.results!.length,
                                                padding:
                                                    EdgeInsets.only(top: 0),
                                                itemBuilder: (context, index) {
                                                  var result =
                                                      data!.results![index];
                                                  // .where((element) =>
                                                  //     element
                                                  //         .geometry!.location !=
                                                  //     null)
                                                  // .toList()[index];
                                                  return ListTile(
                                                    onTap: () {
                                                      selecteData = LocationResult(
                                                          address: result
                                                              .formattedAddress,
                                                          allData: data,
                                                          placeId:
                                                              result.placeId,
                                                          latLng: LatLng(
                                                              result
                                                                  .geometry!
                                                                  .location!
                                                                  .lat!,
                                                              result
                                                                  .geometry!
                                                                  .location!
                                                                  .lng!));
                                                      setState(() {});
                                                      // Navigator.pop(
                                                      //     context,
                                                      //     LocationResult(
                                                      //         address:
                                                      //             result.formattedAddress,
                                                      //         latLng: selectedPostion,
                                                      //         placeId: result.placeId));
                                                    },
                                                    leading: Container(
                                                        padding:
                                                            EdgeInsets.all(7),
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      100),
                                                          color: primaryColor,
                                                        ),
                                                        child: Icon(
                                                          Icons.location_on,
                                                          color: surfaceColor,
                                                        )),
                                                    title: Text(
                                                      result.formattedAddress!,
                                                    ),
                                                    // subtitle: Text(
                                                    //   result.geometry!.location!.lat
                                                    //       .toString(),
                                                    // ),
                                                  );
                                                }),
                                      ))));
                })
                //          Align(
                //   alignment:  Alignment.bottomCenter,
                //   child: Padding(
                //     padding:   EdgeInsets.all(16.0),
                //     child: Card(
                //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                //       child:Padding(
                //           padding: const EdgeInsets.all(16.0),
                //           child: Row(
                //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //             children: <Widget>[
                //               // Flexible(
                //               //   flex: 20,
                //               //   child: FutureLoadingBuilder<Map<String, String?>?>(
                //               //     future: getAddress(locationProvider.lastIdleLocation),
                //               //     mutable: true,
                //               //     loadingIndicator: Row(
                //               //       mainAxisAlignment: MainAxisAlignment.center,
                //               //       children: <Widget>[
                //               //         CircularProgressIndicator(),
                //               //       ],
                //               //     ),
                //               //     builder: (context, data) {
                //               //       _address = data!["address"];
                //               //       _placeId = data["placeId"];
                //               //       return Text(
                //               //         _address ??
                //               //             S.of(context)?.unnamedPlace ??
                //               //             'Unnamed place',
                //               //         style: TextStyle(fontSize: 18),
                //               //       );
                //               //     },
                //               //   ),
                //               // ),
                //               Spacer(),
                //               FloatingActionButton(
                //                 onPressed: () {
                //                   Navigator.of(context).pop({
                //                     'location': LocationResult(
                //                       latLng: locationProvider.lastIdleLocation,
                //                       address: _address,
                //                       placeId: _placeId,
                //                     )
                //                   });
                //                 },
                //                 child:
                //                     Icon(Icons.arrow_forward),
                //               ),
                //             ],
                //           ),
                //         );
                //      ,
                //     ),
                //   ),
                // )
              ],
            ),
          ),
        ],
      ),
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: _goToTheLake,
      //   label: Text('To the lake!'),
      //   icon: Icon(Icons.directions_boat),
      // ),
    );
  }

  Future<void> goToThePosition(LatLng latLng) async {
    getAddress(widget.initialPosition);
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        bearing: 0,
        target: latLng,
        tilt: 0,
        zoom: await controller.getZoomLevel())));
  }
}
