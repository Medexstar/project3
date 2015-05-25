require 'matrix'

class Regression < ActiveRecord::Base
	attr_reader :r_sqrd, :coefficients
	
	@coefficients = []
	@r_sqrd = 0.0
    def self.calc_best_regression time_array, y_array
    	poly = PolyRegression.new(time_array, y_array)
    end
    
    #Calculate the R^2 value to compare best fit
    def calc_rsquared degree
        @n = @y_array.length
        @model_y_array = []
    end
    
    def calc_prediction time
    end
end

class PolyRegression < Regression
	def initialize time_array, y_array
        @x_array = time_array
        @y_array = y_array
		calc_regression
	end
	
	def calc_regression
		r2_values = []
        #Perform regression on all polynomial orders
        (1..10).each do |degree|
            poly_reg(degree)
            @coefficients = @coefficients.map {|i| i.round(2)}
            r2_values << calc_rsquared(degree)
        end
        #Choose best fit polynomial equation based on R^2 value
        puts r2_values
        degree = r2_values.index(r2_values.max) + 1
        @r_sqrd = r2_values.max
        poly_reg(degree)
	end
	
	#Polynomial regression using matrix transformation
    def poly_reg degree
        x_data = @x_array.map { |x_i| (0..degree).map { |pow| (x_i**pow).to_f } }
        mx = Matrix[*x_data]
        my = Matrix.column_vector(@y_array)
        @coefficients = ((mx.t * mx).inv * mx.t * my).transpose.to_a[0]
    end
    
    #Calculate the R^2 value to compare best fit
    def calc_rsquared degree
    	super(degree)
        #Apply calculated equation and place y values into 'model_y_array'
        (0...@n).each do |i|
            estimate = 0
            (0..degree).each do |j|
                estimate += @coefficients[j]*@x_array[i]**j
            end
            @model_y_array << estimate
        end
        #Calculate mean, and respective R^2 components
        mean = @y_array.inject(0) {|sum, i| sum + i} / @n
        sse = (0...@n).inject(0) {|sum, i| sum + (@y_array[i] - @model_y_array[i])**2}
        sst = (0...@n).inject(0) {|sum, i| sum + (@y_array[i] - mean)**2}
        r_sqrd = (1-sse/sst)
        if r_sqrd.nan?
        	return 1.0
        else
        	return r_sqrd
        end
    end
    
    def calc_prediction time
    	i = 0
    	value = 0
    	@coefficients.each do |coefficient|
    		value += coefficient * (time ** i)
    		i += 1
    	end
    	return value
    end
    	
end

class ExpoRegression < Regression
end

class LogRegression < Regression

end