class Aggregator
  attr_reader :trains, :stations, :routes, :passenger_cars, :cargo_cars


  def initialize
    @stations = []
    @trains = []
    @routes = []
    @passenger_cars = []
    @cargo_cars = []
  end

  def new_station
    p 'Enter the name of new station:'
    station_name = gets.chomp.to_s
    @stations << Station.new(station_name)
  rescue RuntimeError => e
    p "Try again. #{e.message}"
    retry
  end

  def new_train
    puts %Q(
    Select the type of new train:
    1. Passenger
    2. Cargo)
    @@type_of_item = gets.chomp
    validate_type_of_item!
    p 'Enter the number of new train'
    number_of_train = gets.chomp
    if @@type_of_item == '1'
      @trains << PassengerTrain.new(number_of_train)
      p "There has been new passenger train whith number #{number_of_train} created"
    elsif @@type_of_item == '2'
      @trains << CargoTrain.new(number_of_train)
      p "There has been new cargo train whith number #{number_of_train} created"
    end
  rescue RuntimeError => e
    p "Try again. #{e.message}"
    retry
  end

  def new_car
    puts %Q(
    Select the type of new car:
    1. Passenger
    2. Cargo)
    @@type_of_item = gets.chomp
    validate_type_of_item!
    p 'Enter the number of new car'
    @number_of_car = gets.chomp
    if @@type_of_item == '1'
      @passenger_cars << PassengerCar.new(@number_of_car)
    elsif @@type_of_item == '2'
      @cargo_cars << CargoCar.new(@number_of_car)
    end
  rescue RuntimeError => e
    p "Try again. #{e.message}"
    retry
  end

  def new_route
    p 'Choose the first station of new route:'
    number_first = select_station
    @routes << Route.new(number_first, nil)
    p 'Choose the last station of new route:'
    number_last = select_station
    @routes.last.route[-1] = number_last
    raise 'The first station in the route must be different from the last' if number_first == number_last
  rescue RuntimeError => e
    p "Try again. #{e.message}"
    retry
  end


  def add_station
    puts 'Choose the route to add the station'
    @subject_route = select_route
    p 'Choose the station to add:'
    station_number = select_station
    @subject_route.add_station(station_number)
  rescue RuntimeError => e
    p "Try again. #{e.message}"
    retry
  end

  def delete_station
    puts 'Choose the route to delete the station'
    @subject_route = select_route
    p 'Choose the station to delete:'
    station_number = select_station
    @subject_route.delete_station(station_number)
  rescue RuntimeError => e
    p "Try again. #{e.message}"
    retry
  end

  def train_on_route
    puts 'Choose the train to set on the route'
    @subject_train = select_train
    puts 'Choose the route to set'
    @subject_route = select_route
    @subject_train.set_route(@subject_route)
  rescue RuntimeError => e
    p "Try again. #{e.message}"
    retry
  end

  def attach_car
    puts 'Choose the train to attach a car'
    @subject_train = select_train
    if @subject_train.speed != 0
      p 'Train is on the route. It should be stopped to attach a car'
    else
      if @subject_train.class == CargoTrain
        @car_array = @cargo_cars
      elsif @subject_train.class == PassengerTrain
        @car_array = @passenger_cars
      end
      inner_method_attach(@car_array)
    end
  rescue RuntimeError => e
    p "Try again. #{e.message}"
    retry
  end

  def detach_car
    puts 'Choose the train to detach a car'
    @subject_train = select_train
    if @subject_train.speed != 0
      p 'Train is on the route. It should be stopped to detach a car'
    else
      puts 'Choose the car to detach'
      @subject_train.train_cars.each do |car|
        p "#{(@subject_train.train_cars.index(car)+1)}. #{car.number}"
      end
      @number_of_car = gets.chomp.to_i
      validate_car!
      @subject_train.train_cars.delete(@subject_train.train_cars[@number_of_car - 1])
    end
  rescue RuntimeError => e
    p "Try again. #{e.message}"
    retry
  end

  def move_forvard
    puts 'Choose the train to move forvard along the route'
    @subject_train = select_train
    @subject_train.next_station
  rescue RuntimeError => e
    p "Try again. #{e.message}"
    retry
  end

  def move_back
    puts 'Choose the train to move back along the train'
    @subject_train = select_train
    @subject_train.prevous_station
  rescue RuntimeError => e
    p "Try again. #{e.message}"
    retry
  end

  def aggregator_report
    @stations.each do |station|
      if station.station_trains.empty? == true
        p "Station - #{station.station_name} has no trains"
      elsif station.station_trains.empty? == false
        p "Station - #{station.station_name} has trains numbered:"
        support_array = station.station_trains
        support_for_report(support_array)
      end
    end
  end

  protected

  #Вспомогательные методы

  def inner_method_attach(car_array)
    @car_array = car_array
    puts 'Choose the car to attach'
    @car_array.each do |car|
      p "#{(@car_array.index(car)+1)}. #{car.number}"
    end
    @number_of_car = gets.chomp.to_i
    validate_car!
    @subject_train.attach_car(@car_array[@number_of_car - 1])
  end

  def support_for_report(support_array)
    support_array.each do |trains|
      p trains.number
    end
  end

  def select_route
    @routes.each.with_index(1) do |support_route, index|
      p "#{support_for_routes(support_route.route)} press #{index}"
    end
    @number_of_route = gets.chomp.to_i
    validate_routes!
    @routes[@number_of_route - 1]
  end

  def support_for_routes(sup_route)
    sup_route.each do |station|
      print "#{station.station_name} - "
    end
    return nil
  end

  def show_trains
    @trains.each.with_index(1) do |train, index|
      puts "#{index}. #{train.number}"
    end
  end

  def select_train
    show_trains
    @number_of_train = gets.chomp.to_i
    validate_trains!
    @trains[@number_of_train - 1]
  end

  def select_station
    @stations.each do |station|
      p "#{(@stations.index(station)+1)}. #{station.station_name}"
    end
    @station_number = gets.chomp.to_i
    validate_route_stations!
    @stations[@station_number - 1]
  end

  def validate_type_of_item!
    raise 'Item type must be passenger(1) or cargo(2)' if ['1','2'].include?(@@type_of_item) == false
  end

  def validate_route_stations!
    @subject_array = @stations
    @subject_item = @station_number
    @item = 'station'
    validate_item!
  end

  def validate_routes!
    @subject_array = @routes
    @subject_item = @number_of_route
    @item = 'route'
    validate_item!
  end

  def validate_trains!
    @subject_array = @trains
    @subject_item = @number_of_train
    @item = 'train'
    validate_item!
  end

  def validate_car!
    @subject_array = @car_array
    @subject_item = @number_of_car
    @item = 'car'
    validate_item!
  end

  def validate_item!
    avaliable_numbers = []
    @subject_array.each do |item|
      avaliable_numbers << (@subject_array.index(item)+1)
    end
    raise "There is no such #{@item}" if avaliable_numbers.include?(@subject_item) == false
  end
end
