require 'minitest/autorun'
require 'timeout'

class CustomerSuccessBalancing
  def initialize(customer_success, customers, away_customer_success)
    @customer_success = customer_success
    @customers = customers
    @away_customer_success = away_customer_success
  end

  # Returns the ID of the customer success with most customers
  def execute
    
    if @customer_success == []
       return "Don't have any customer success"
    elsif @customers == []
      return "Don't have any customer"
    end

    customers_success        = available_customer(@customer_success, @away_customer_success)
    customers_success_sorted = customers_success.sort_by {|order| order[:score]}
    customers_sorted         = @customers.sort_by {|order| order[:score]}

    list =  number_of_clients_for_customer(customers_success_sorted, customers_sorted)

    return customer_success_with_more_customers(list)

  end
  
  # Returns employees who are available for work
  def available_customer(customers_success, ids_customers_away)
    ids_customers_away.each do |id_away|
      customers_success.each do |customer_success|
        if customer_success[:id] == id_away
          customers_success.delete(customer_success)
        end
      end
    end
    return customers_success
  end

  # Returns a descending list associating the customer succes id with the number of customers
  def number_of_clients_for_customer(customers_success, customers)
    # count_client = 0
    number_client = 0
    aux = 0
    list_of_customer = []

    customers_success.each do |customer_success|
        for index in (aux...customers.length)
            aux = aux + 1
            if customers[index][:score] <= customer_success[:score]
                number_client = number_client + 1
            else
                break
            end
        end   
    #   number_client = number_client - count_client
      list_of_customer = list_of_customer.push({ id: customer_success[:id] , clients: number_client })
    #   count_client = number_client + count_client
      number_client = 0
    end
    return list_of_customer.sort_by {|order| order[:clients]}.reverse!
  end

  # Returns the id of the customer succes who has the most customers, if there is a tie, the return will be "0"
  def customer_success_with_more_customers(list)
    if list[0][:clients] == list[1][:clients]
      return 0
    end
    return list[0][:id]
  end

end

class CustomerSuccessBalancingTests < Minitest::Test
  def test_scenario_one
    balancer = CustomerSuccessBalancing.new(
      build_scores([60, 20, 95, 75]),
      build_scores([90, 20, 70, 40, 60, 10]),
      [2, 4]
    )
    assert_equal 1, balancer.execute
  end

  def test_scenario_two
    balancer = CustomerSuccessBalancing.new(
      build_scores([11, 21, 31, 3, 4, 5]),
      build_scores([10, 10, 10, 20, 20, 30, 30, 30, 20, 60]),
      []
    )
    assert_equal 0, balancer.execute
  end

  def test_scenario_three
    balancer = CustomerSuccessBalancing.new(
      build_scores(Array(1..999)),
      build_scores(Array.new(10000, 998)),
      [999]
    )
    result = Timeout.timeout(1.0) { balancer.execute }
    assert_equal 998, result
  end

  def test_scenario_four
    balancer = CustomerSuccessBalancing.new(
      build_scores([1, 2, 3, 4, 5, 6]),
      build_scores([10, 10, 10, 20, 20, 30, 30, 30, 20, 60]),
      []
    )
    assert_equal 0, balancer.execute
  end

  def test_scenario_five
    balancer = CustomerSuccessBalancing.new(
      build_scores([100, 2, 3, 3, 4, 5]),
      build_scores([10, 10, 10, 20, 20, 30, 30, 30, 20, 60]),
      []
    )
    assert_equal 1, balancer.execute
  end

  def test_scenario_six
    balancer = CustomerSuccessBalancing.new(
      build_scores([100, 99, 88, 3, 4, 5]),
      build_scores([10, 10, 10, 20, 20, 30, 30, 30, 20, 60]),
      [1, 3, 2]
    )
    assert_equal 0, balancer.execute
  end

  def test_scenario_seven
    balancer = CustomerSuccessBalancing.new(
      build_scores([100, 99, 88, 3, 4, 5]),
      build_scores([10, 10, 10, 20, 20, 30, 30, 30, 20, 60]),
      [4, 5, 6]
    )
    assert_equal 3, balancer.execute
  end

  private

  def build_scores(scores)
    scores.map.with_index do |score, index|
      { id: index + 1, score: score }
    end
  end
end
