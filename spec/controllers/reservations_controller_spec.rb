require 'spec_helper'
include LoginHelper

RSpec.describe ReservationsController, type: :controller do

  before(:each) do
    login_as_donor
    @therapist = FactoryGirl.create(:therapist_user)
    @list = FactoryGirl.create(:list, therapist: @therapist.role)
    @gift_request = FactoryGirl.create(:gift_request, list_id: @list.id)
    @reservation = FactoryGirl.create(:reservation, gift_request_id: @gift_request.id, donor_id: @user.id)
  end


  describe "POST #ship" do
    it "moves a reservation from reserved to shipped" do

      expect(@reservation.state).to eq('reserved')

      post :ship, id: @reservation.id

      expect(response.status).to eq(200)

      @reservation.reload
      expect(@reservation.state).to eq('shipped')
    end

    it "renders errors on unsuccessful shipping" do
      @reservation.ship

      post :ship, id: @reservation.id

      expect(response.status).to eq(500)
    end

    it "should only be accessible to donors" do
      login_as_therapist

      post :ship, id: @reservation.id

      expect(response).to redirect_to root_path
    end
  end


  describe "DELETE #destroy" do
    it "deletes a reservation" do

      request.env["HTTP_REFERER"] = '/catalog'

      delete :destroy, id: @reservation.id

      expect(response).to redirect_to '/catalog'
      expect(Reservation.all.length).to eq(0)

    end

    it "should not delete received reservations" do
      @reservation.ship
      @reservation.receive

      expect(@reservation.state).to eq('received')

      request.env["HTTP_REFERER"] = '/catalog'

      delete :destroy, id: @reservation.id

      expect(response).to redirect_to '/catalog'
    end

  end



end