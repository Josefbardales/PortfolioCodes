#!/usr/bin/env python
# coding: utf-8

# In[1]:


import pandas as pd
import matplotlib.pyplot as plt

# Assuming your data is in a CSV file named "data.csv"
data = pd.read_csv(r'C:\Users\JFB\Documents\Pythoncsv\OrganicInstallTestData.csv')

# Convert 'Date' column to datetime format
data['Date'] = pd.to_datetime(data['Date'])
data.set_index('Date', inplace=True)


# In[2]:


# Plot the data
data['installs'].plot(figsize=(12, 6))
plt.title('Installs over Time')
plt.ylabel('Installs')
plt.show()


# In[3]:


from statsmodels.tsa.stattools import adfuller

result = adfuller(data['installs'])
print('ADF Statistic:', result[0])
print('p-value:', result[1])

# if p-value < 0.05, data is stationary


# In[6]:


from pmdarima import auto_arima

model = auto_arima(data['installs'], seasonal=True, m=7, trace=True, error_action='ignore', suppress_warnings=True)
model.fit(data['installs'])

forecast = model.predict(n_periods=182)
forecast_series = pd.Series(forecast, index=pd.date_range(start='2023-01-01', periods=182, freq='D'))

# Plotting the forecast
plt.figure(figsize=(12, 6))
plt.plot(data.index, data['installs'], label='Historical')
plt.plot(forecast_series.index, forecast_series, label='Forecast', color='red')
plt.title('Installs Forecast')
plt.ylabel('Installs')
plt.legend()
plt.show()


# In[7]:


from statsmodels.tsa.statespace.sarimax import SARIMAX

# Fit the best model
model = SARIMAX(data['installs'], order=(1, 1, 3), seasonal_order=(2, 0, 0, 7))
results = model.fit(disp=-1)

# Forecast for the next 182 days
forecast = results.get_forecast(steps=182).predicted_mean

# Create a new series for forecast values
forecast_series = pd.Series(forecast, index=pd.date_range(start='2023-01-01', periods=182, freq='D'))


# In[8]:


# Aggregate the forecast by month
monthly_forecast = forecast_series.resample('M').sum()

# Print the aggregated values
print(monthly_forecast)


# In[ ]:




