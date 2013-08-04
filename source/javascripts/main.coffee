host = apiHost
$w = $ window
$d = $ document
$b = $ 'body'
$loadMore = $('.js-load-more')
$shareButtons = $('.share-facebook, .share-twitter')

HistorySupportAvailable = -> !!(window.history && history.pushState)
HistoryPushURL = (url) ->
  $shareButtons.data('url', url)
  if HistorySupportAvailable()
    history.pushState {}, $('title').text(), url

isScrolledIntoView = ($e) ->
  return false if !$e? || !$e.is(":visible")
  docViewTop = $w.scrollTop()
  docViewBottom = docViewTop + $w.height()
  elemTop = $e.offset().top
  elemBottom = elemTop + $e.height()
  ((elemBottom <= docViewBottom) && (elemTop >= docViewTop))

$.fn.serializeObject = ->
  o = {}
  a = @serializeArray()
  $.each a, ->
    if o[@name] isnt `undefined`
      o[@name] = [o[@name]]  unless o[@name].push
      o[@name].push @value or ""
    else
      o[@name] = @value or ""
  o

PlacesAppend = (response) ->
  $places = $('.places')
  templateId = $places.data('template-id')
  nextRows = ''

  currentPageParams = $loadMore.data('params')
  currentPageQueryString = ''
  currentPageQueryString = '?' + $.param(currentPageParams) if currentPageParams?
  HistoryPushURL window.location.origin + window.location.pathname + currentPageQueryString

  if currentPageParams? && (!currentPageParams.offset || parseInt(currentPageParams.offset, 10) == 0)
    if !response.data? || response.data.length == 0
      templateId = $places.data('template-no-result-id')
      $places.append $('#' + templateId).html() if templateId?

  for resource in response.data
    nextRows += tmpl(templateId, resource)
  $places.append nextRows
  $('body').addClass 's-collapse-titles'
  if response.pageParams? && response.pageParams.next?
    nextPageParams = $.extend({}, currentPageParams, response.pageParams.next)
    $loadMore.data('params', nextPageParams)
    DoLoadMore() if isScrolledIntoView($loadMore)
  else
    $loadMore.data('url', null)
    $loadMore.data('params', null)
    $loadMore.hide()

isLoadingMore = false
DoLoadMore = ->
  if $loadMore?
    url = $loadMore.data('url')
    if url && !isLoadingMore
      isLoadingMore = true
      $loadMore.show()
      $.ajax
        type: "GET"
        url: url
        dataType: 'json'
        data: $loadMore.data('params')
        success: (response) ->
          isLoadingMore = false
          PlacesAppend(response)

LoadMoreIfAllowed = -> DoLoadMore() if isScrolledIntoView($loadMore)


# --------------
LoadMoreIfAllowed()
$w.bind 'scrollstop', LoadMoreIfAllowed

$searchForm = $('form.pencarian')

$searchForm.on 'submit', ->
  $('.places').empty()
  $t = $ this
  url = $t.attr('action')
  if $loadMore?
    $loadMore.show()
    $loadMore.data('url', url)
    $loadMore.data('params', $t.serializeObject())

  $.ajax
    type: 'GET'
    url: url
    dataType: 'json'
    data: $t.serialize()
    success: PlacesAppend
  return false

if $searchForm.length > 0
  paramPair = window.location.search.substring(1).split('&')
  shouldSubmit = false
  for paramString in paramPair
    [key, value] = paramString.split('=')
    key = decodeURIComponent key
    value = decodeURIComponent value
    if value? && value.length > 0
      shouldSubmit = true if key == 'city' || key == 'street' || key == 'postalCode'
      $("#place-#{key}").val(value)

  $searchForm.submit() if shouldSubmit

$('.share-facebook').on 'click', ->
  $t = $ this
  sharer = "https://www.facebook.com/sharer/sharer.php?u=";
  window.open(sharer + ($t.data('url') || window.location.href), 'sharer', 'width=626,height=436');

$('.share-twitter').on 'click', ->
  $t = $ this
  sharer = "https://twitter.com/intent/tweet?"
  params =
    hashtags: $t.data('hashtags'),
    original_referer: window.location.href,
    text: $('title').text(),
    tw_p: "tweetbutton",
    url: $t.data('url') || window.location.href
  window.open(sharer + $.param(params), 'sharer', 'width=626,height=436');

$ ->
  $('#place-city').autocomplete(
    serviceUrl: "#{host}/autocomplete/cities.json"
    minChars: 3
  )
  $('#place-postalCode').autocomplete(
    serviceUrl: "#{host}/autocomplete/postalCodes.json"
    minChars: 3
    onSelect: (value, data) -> $(this.form).submit()
  )