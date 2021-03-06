class BookingsController < ApplicationController

  def show
    @booking = Booking.find(params[:id])
    @flight = @booking.flight
    @passengers = @booking.passengers
  end

  def new
    @flight = Flight.find_by(id: params[:booking][:flight_id])
    @booking = Booking.new
    @passengers = build_passengers_new
  end

  def create
    @flight = Flight.find_by(id: params[:booking][:flight_id])
    @booking = Booking.new
    @booking.flight_id = params[:booking][:flight_id]
    build_passengers_create

    if @booking.save
      PassengerMailer.confirmation_email(@booking).deliver_later
      redirect_to @booking
      flash[:info] = "Flight booked!"
    else
      flash.now[:danger] = "Enter name / email!"
      render :new
    end
  end

  private

  def build_passengers_create
    params[:booking][:passengers_attributes].each do | _k, value|
      @booking.passengers.build(
        name:   value["name"],
        email:  value["email"]
        )
    end
  end

  def build_passengers_new
    num_of_tickets = params[:booking][:num_of_tickets].to_i
    num_of_tickets.times { @booking.passengers.build }
    @booking.passengers
  end

  def bookings_params
    params.require(:booking)
          .permit(:flight_id, passengers_attributes: [:name, :email])
  end

end
