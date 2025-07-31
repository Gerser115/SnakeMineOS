-- Простая змейка для MineOS (без вылетов)
local event = require("event")
local component = require("component")
local gpu = component.gpu
local computer = require("computer")

-- Очищаем экран
gpu.setResolution(40, 20)
gpu.setBackground(0x000000)
gpu.fill(1, 1, 40, 20, " ")

-- Параметры игры
local snake = {{x=20, y=10}, {x=19, y=10}, {x=18, y=10}}
local food = {x=25, y=10}
local dir = "right"
local score = 0
local speed = 0.15

-- Отрисовка
local function draw()
  -- Очищаем только игровое поле (не весь экран)
  gpu.fill(2, 2, 36, 16, " ")
  
  -- Рисуем змейку
  gpu.setBackground(0x00FF00)
  for _, part in ipairs(snake) do
    gpu.set(part.x, part.y, " ")
  end
  
  -- Рисуем еду
  gpu.setBackground(0xFF0000)
  gpu.set(food.x, food.y, " ")
  
  -- Счет
  gpu.setBackground(0x000000)
  gpu.setForeground(0xFFFFFF)
  gpu.set(2, 1, "Счет: "..score)
end

-- Генерация новой еды
local function newFood()
  while true do
    food.x = math.random(2, 39)
    food.y = math.random(2, 17)
    local ok = true
    for _, part in ipairs(snake) do
      if part.x == food.x and part.y == food.y then
        ok = false
        break
      end
    end
    if ok then break end
  end
end

-- Основной цикл
while true do
  -- Обработка управления
  local e = {event.pull(speed, "key_down")}
  if e[1] == "key_down" then
    if e[4] == 200 and dir ~= "down" then dir = "up" end
    if e[4] == 208 and dir ~= "up" then dir = "down" end
    if e[4] == 203 and dir ~= "right" then dir = "left" end
    if e[4] == 205 and dir ~= "left" then dir = "right" end
  end
  
  -- Движение змейки
  local head = {x=snake[1].x, y=snake[1].y}
  if dir == "up" then head.y = head.y - 1 end
  if dir == "down" then head.y = head.y + 1 end
  if dir == "left" then head.x = head.x - 1 end
  if dir == "right" then head.x = head.x + 1 end
  
  -- Проверка столкновений
  if head.x < 2 or head.x > 39 or head.y < 2 or head.y > 17 then
    break -- Конец игры
  end
  
  for i=2, #snake do
    if snake[i].x == head.x and snake[i].y == head.y then
      break -- Конец игры
    end
  end
  
  -- Добавляем новую голову
  table.insert(snake, 1, head)
  
  -- Проверка еды
  if head.x == food.x and head.y == food.y then
    score = score + 10
    newFood()
  else
    table.remove(snake)
  end
  
  draw()
end

-- Конец игры
gpu.setBackground(0x000000)
gpu.fill(1, 1, 40, 20, " ")
gpu.setForeground(0xFFFFFF)
gpu.set(15, 10, "Игра окончена! Счет: "..score)
gpu.set(12, 11, "Закройте окно для выхода")
