require_relative '../../../app/api'

require 'rack/test'

module ExpenseTracker
  RSpec.describe API do
    include Rack::Test::Methods

    def app
      API.new(ledger: ledger)
    end

    let(:ledger) { instance_double('ExpenseTracker::Ledger') }

    describe 'POST /expenses' do
      context 'when the expense is successfully recorded' do
        let(:expense) { { 'some' => 'data' } }

        before do
          allow(ledger).to receive(:record)
            .with(expense)
            .and_return(RecordResult.new(true, 417, nil))
        end

        it 'returns the expense id' do
          post '/expenses', JSON.generate(expense)
          parsed = JSON.parse(last_response.body)
          expect(parsed).to include('expense_id' => 417)
        end

        it 'responds with a 200 (OK)' do
          post '/expenses', JSON.generate(expense)

          expect(last_response.status).to eq(200)
        end
      end

      context 'when the expense fails validation' do
        before do
          allow(ledger).to receive(:record)
            .with(expense)
            .and_return(RecordResult.new(false, 417, 'Expense incomplete'))
        end
        it 'returns an error message'
        pending it 'responds with a 422 (Unprocessable entity)' do

        it 'returns an error message' do
          post '/expenses', JSON.generate(expense)

          parsed = JSON.parse(last_response.body)
          expect(parsed).to include('error' => 'Expense incomplete')
        end
        it 'responds with a 422 (Unprocessable entity)' do
          post '/expenses', JSON.generate(expense)
          expect(last_response.status).to eq(422)
        end
      end
    end

    describe 'GET /expenses/:date' do
      context 'when an expenses exist on the given date' do
        expenses = [
          { 'id' => '1' },
          { 'id' => '2' }
        ]

        it 'returns the expense records as JSON' do
          allow(ledger).to receive(:expenses_on)
            .with('2017-06-12')
            .and_return(JSON.generate(expenses))
        end

        it 'responds with a 200 (OK)' do
          allow(ledger).to receive(:expenses_on)
            .with('2017-06-12')
            .and_return(JSON.generate(expenses))

          get '/expenses/2017-06-12'
          expect(last_response.status).to eq(200)
        end
      end

      context 'when there are no expenses on the given date' do
        expenses = []
        it 'returns an empty array as JSON' do
          allow(ledger).to receive(:expenses_on)
            .with('2017-06-12')
            .and_return(JSON.generate(expenses))

          get '/expenses/2017-06-12'
          parsed = JSON.parse(last_response.body)
          expect(parsed).to eq("[]")
        end
        it 'responds with a 200 (OK)' do
          allow(ledger).to receive(:expenses_on)
            .with('2017-06-12')
            .and_return(JSON.generate(expenses))

          get '/expenses/2017-06-12'
          expect(last_response.status).to eq(200)
        end
      end
    end
  end
end
