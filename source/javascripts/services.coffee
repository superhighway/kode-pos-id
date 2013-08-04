host = apiHost
w = window
defaultLimit = 40
defaultOffset = 0

currentLocationSearch =  ->
  params = {}
  paramPair = w.location.search.substring(1).split('&')
  for paramString in paramPair
    [key, value] = paramString.split('=')
    key = decodeURIComponent key
    value = decodeURIComponent value
    if value? && value.length > 0
      params[key] = value
  params

app = angular.module('kodeposApp', ['infinite-scroll'])

app.factory "placesService", [
  '$http', ($http) ->
    getPath = (path, params) ->
      $http(
        url: apiHost + path
        method: 'GET'
        params: params
      )
    getPlaces: (params) ->
      getPath '/places.json', params
    getPostalCodes: (params) ->
      getPath '/postalCodes.json', params
    getCities: (params) ->
      getPath '/cities.json', params
  ]

app.controller "PlacesCtrl", [
  '$scope', 'placesService', '$timeout',
  ($scope, placesService, $timeout) ->
    $cityAutocomplete = $('#place-city')
    $cityAutocomplete.autocomplete(
      serviceUrl: "#{host}/autocomplete/cities.json"
      minChars: 3
      onSelect: (value, data) ->
        $cityAutocomplete.trigger('input');
    )
    $postalCodeAutocomplete = $('#place-postalCode')
    $postalCodeAutocomplete.autocomplete(
      serviceUrl: "#{host}/autocomplete/postalCodes.json"
      minChars: 3
      onSelect: (value, data) ->
        $postalCodeAutocomplete.trigger('input');
        $(this.form).submit()
    )

    $scope.submitted = false
    $scope.loading = false

    $scope.submit = ->
      $scope.loading = true
      params = $scope.place || {}
      params.limit ||= defaultLimit
      params.offset = defaultOffset
      placesService.getPlaces(params).then((res) ->
        $scope.submitted = true
        list = $scope.list = res.data.data
        page = $scope.pageParams = res.data.pageParams
        $scope.noResult = !page.next? && (!list || list.length == 0)
        $scope.loading = false
      )

    $scope.fetchNext = ->
      return if $scope.loading || !$scope.place? || !$scope.list? || !$scope.pageParams.next?
      $scope.loading = true
      params = $scope.place
      params.limit = $scope.pageParams.next.limit || defaultLimit
      params.offset = ($scope.pageParams.next.offset || defaultOffset)
      placesService.getPlaces(params).then((res) ->
        list = res.data.data
        page = $scope.pageParams = res.data.pageParams
        for p in list
          $scope.list.push p
        $scope.noResult = false
        $scope.loading = false
      )

    search = currentLocationSearch()
    if search.city? || search.postalCode? || search.street?
      $scope.place = search
      $scope.submit()
  ]

app.controller 'PostalCodesCtrl', [
  '$scope', 'placesService',
  ($scope, placesService) ->
    postalCodesLimit = 80
    $scope.loading = true
    params = { offset: defaultOffset, limit: postalCodesLimit }
    placesService.getPostalCodes(params).then((res) ->
      $scope.list = res.data.data
      $scope.pageParams = res.data.pageParams
      $scope.loading = false
    )

    $scope.fetchNext = ->
      return if $scope.loading || !$scope.list? || !$scope.pageParams.next?
      $scope.loading = true
      params = {}
      params.limit = $scope.pageParams.next.limit || postalCodesLimit
      params.offset = ($scope.pageParams.next.offset || defaultOffset)
      placesService.getPostalCodes(params).then((res) ->
        list = res.data.data
        page = $scope.pageParams = res.data.pageParams
        for p in list
          $scope.list.push p
        $scope.loading = false
      )
  ]

app.controller 'CitiesCtrl', [
  '$scope', 'placesService',
  ($scope, placesService) ->
    $scope.loading = true
    params = { offset: defaultOffset, limit: defaultLimit }
    placesService.getCities(params).then((res) ->
      $scope.list = res.data.data
      $scope.pageParams = res.data.pageParams
      $scope.loading = false
    )

    $scope.fetchNext = ->
      return if $scope.loading || !$scope.list? || !$scope.pageParams.next?
      $scope.loading = true
      params = {}
      params.limit = $scope.pageParams.next.limit || defaultLimit
      params.offset = ($scope.pageParams.next.offset || defaultOffset)
      placesService.getCities(params).then((res) ->
        list = res.data.data
        page = $scope.pageParams = res.data.pageParams
        for p in list
          $scope.list.push p
        $scope.loading = false
      )
  ]

app.controller 'ShareCtrl', [
  '$scope', ($scope) ->
    $scope.shareOnTwitter = ->
      sharer = "https://twitter.com/intent/tweet?"
      href = w.location.href
      params =
        hashtags: ""
        original_referer: href
        text: $('title').text()
        tw_p: "tweetbutton"
        url: href
      w.open(sharer + $.param(params), 'sharer', 'width=626,height=436')
    $scope.shareOnFacebook = ->
      sharer = "https://www.facebook.com/sharer/sharer.php?u=";
      w.open(sharer + (w.location.href), 'sharer', 'width=626,height=436')
  ]
