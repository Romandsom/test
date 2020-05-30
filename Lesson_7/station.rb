class Station
  include InstanceCounter
  include Validate
  attr_reader :station_name, :station_trains
  @@station_roster = []

  TRAIN_BLOCK  = Proc.new do
    |train|
    if train.is_a?(CargoTrain)
      type = 'cargo'
    elsif train.is_a?(PassengerTrain)
      type = 'passenger'
    end
    p "Train ##{train.number} is a #{type} train, it has #{train.train_cars.count} cars"
    train.each_wagon
  end

  def initialize(station_name)
    @station_name = station_name
    @station_trains = []
    @@station_roster << self
    register_instance
    validate!
  end

  def self.all
    @@station_roster
  end

  def support_for_report(support_array)
    support_array.each do |trains|
      p trains.number
    end
  end

  #protected
  #если делаю эти два метода "protected", то программа перестает работать, почему?

  def train_leaving(train)
    @station_trains.delete(train)
    @@station_roster.delete(self)
  end

  def train_arriving(train)
    @station_trains << train
    @@station_roster << self
  end

  def each_train(&block)
    @station_trains.each { |train| TRAIN_BLOCK.call(train) }
  end

  protected

  def validate!
    raise "Station must have a name" if station_name.empty?
    raise "Station name must consist of word characters, in one word" if station_name !~ /^\w{1}*$/i
    raise "Station name must consist of no more, than 15 word characters in one word" if station_name.length > 15
    true
  end
end
