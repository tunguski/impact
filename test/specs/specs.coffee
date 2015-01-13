describe 'TestCtrl', ->
  beforeEach module 'App'

  $controller = $firebase = $scope = ctrl = null

  beforeEach inject (_$controller_, _$firebase_) ->
    $controller = _$controller_
    $firebase = _$firebase_
    $scope = {}
    ctrl = $controller 'TestCtrl', { $scope: $scope }
  
  describe 'initial state', ->
    it 'has db connection', ->
      expect($scope.db).toBeDefined()
      expect($scope.gameInstance).toBeDefined()
      