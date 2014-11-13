app = angular.module 'App', []

app.controller 'TestCtrl', ($scope, $timeout) ->
  $scope.levels = [1,2,3,4,5,6,7,8,9,10,12,14,16,18,20,22,24,26,30]
  $scope.level = 30

  # empty state
  $scope.emptyState = () ->
    state =
      endGame: false
      points: [0, 0, 0]
      rows: []
      checked: [[], [], []]
    for i in [0..9]
      row = { y: i }
      state.rows.push(row)
      row.cols = ({ x: j, y: i, row: row, pressure : [0, 0, 0], val: [255, 255, 255], owner: -1 } for j in [0..9])
    state

  # state
  $scope.restart = () -> $scope.state = $scope.emptyState()
  $scope.restart()

  # pressure
  pressure = (from, to) ->
    if from == to
      return 1024
    square = (x) -> x * x
    val = 128 / Math.sqrt((square(from.x-to.x) + square(from.y-to.y)))
    if val > 1000000
      console.log('pressure: ' + val)
    return val

  # add pressure
  addPressure = (col, pressure, index) -> col.pressure[index] = col.pressure[index] + pressure

  # recalculate pressure
  recalculatePressure = (state, col) ->
    col.pressure = [0, 0, 0]
    col.val = [0, 0, 0]
    for i in [0..2]
      for pressing in state.checked[i]
        addPressure(col, pressure(pressing, col), i)
      col.val[i] = (255 - Math.min(255, Math.round(col.pressure[i])))
    col.owner = $scope.findOwner(col)

  # recalculate points
  $scope.recalculatePoints = (state) ->
    state.points = [0, 0, 0]
    for row in state.rows
      for col in row.cols
        if col.owner >= 0
          state.points[col.owner] = state.points[col.owner] + 1

  # computer move
  $scope.calculateComputerMove = (actualState, playerIndex) ->
    maxPoints = -1
    maxPressure = -1
    bestMove = null
    for x in [0..9]
      for y in [0..9]
        if actualState.rows[y].cols[x].owner < 0 or actualState.rows[y].cols[x].owner == playerIndex
          state = angular.copy(actualState)
          move = state.rows[y].cols[x]
          $scope.clicked(state, move, playerIndex)
          movePressure = 0
          for i in [0..9]
            for j in [0..9]
              if (i*10 + j + 3) % $scope.level != 0
                #console.log('hidden field ' + i + ' ' + j)
                continue
              movePressure = movePressure + state.rows[i].cols[j].pressure[playerIndex]
              if movePressure > 100000
                console.log('x: ' + j + ' y: ' + i + ' pressure sum: ' + movePressure);
          if state.points[playerIndex] > maxPoints or state.points[playerIndex] == maxPoints and movePressure > maxPressure
            maxPoints = state.points[playerIndex]
            maxPressure = movePressure
            bestMove = move
    return bestMove


  # clicked!
  $scope.clicked = (state, col, userIndex) ->
    if state.endGame
      return
    $scope.info = null
    if typeof col.checked == 'undefined' and (col.owner == -1 or col.owner == userIndex)
      col.checked = userIndex
      state.checked[userIndex].push(col)
      recalculatePressure(state, col) for col in row.cols for row in state.rows
      $scope.recalculatePoints(state)
    else
      $scope.info = 'Próba zajecia zajetego pola'

    if userIndex == 0
      # move in copied state - need to be transformed
      computerMove = $scope.calculateComputerMove(state, 1)
      # transform to this world
      computerMove = state.rows[computerMove.y].cols[computerMove.x]
      $scope.clicked(state, computerMove, 1)
    $scope.checkIfEnd(state)

  # is it end of game?
  $scope.checkIfEnd = (state) ->
    for x in [0..9]
      for y in [0..9]
        if state.rows[y].cols[x].owner < 0
          return false
    state.endGame = true
    true

  # color gradient
  $scope.colorGradient = (row, col) ->
    if typeof col.checked != 'undefined'
      '#ddd'
    else
      color = '#'
      for i in [0..2]
        val = col.val[i].toString(16)
        color = color + ('0' + val).split('')[-2..].join('')
      color

  # find owner
  $scope.findOwner = (col) ->
    value = -1
    owner = -1
    for i in [0..2]
      if col.pressure[i] > value
        value = col.pressure[i]
        owner = i
      else if col.pressure[i] == value
        # if pressure is equal, nobody owns field
        owner = -1
    if col.val[owner] < 64 then owner else -1

  # font color
  $scope.fontColor = (col) ->
    owner = col.owner
    color = '#'
    for i in [0..2]
      color = color + (if i == owner then 'cc' else '00')
    color

  # font style
  $scope.fontStyle = (col) ->
    if col.owner >= 0 then 'italic' else 'initial'


# Array remove()
Array.prototype.remove = (elem) ->
  if this.indexOf(elem) >= 0
    this.splice(this.indexOf(elem), 1)

angular.bootstrap document, ['App']
