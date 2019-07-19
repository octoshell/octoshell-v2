require 'main_spec_helper'
require_relative 'schema'
module OctoInterface
  describe Person do
    before(:each) do
      @person = Person.create!(name: 'George')
      Article.create!(title: 'first', person: @person)
      Article.create!(title: 'second', person: @person)
      Friend.create!(name: 'Alice', person: @person)
      Friend.create!(name: 'Bob', person: @person)

    end
    # it 'returns proxy in foreign_has_many using #to_a' do
    #   expect(@person.articles.to_a.first).to be_instance_of Proxy
    #   expect(@person.articles.to_a.first).to be_instance_of Proxy
    # end
    #
    # it 'returns proxy in foreign_has_many using #take' do
    #   expect(@person.articles.take(2).first).to be_instance_of Proxy
    # end
    #
    # it 'returns child of ApplicationRecord in a usual has_many' do
    #   expect(@person.friends.to_a.first).to be_instance_of Friend
    # end

    it 'forbids modification in foreign_has_many' do
      puts @person.articles.instance_methods.sort.inspect
      @person.articles << Article.new(title: 'new')
      @person.articles.first.title = 'ndnd'
      @person.articles.first.save!

      # expect { @person.articles << Article.new(title: 'new') }.to raise_error(NoMethodError)
    end

    it 'allows modification in has_many' do
      @person.friends << Friend.new(name: 'new')
      expect(@person.friends.count).to eq 3
    end


  end
end
