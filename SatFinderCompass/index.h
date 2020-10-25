const char MAIN_page[] PROGMEM = R"=====(
<!DOCTYPE html>
<html>
<head>

<meta HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<style>
h1 {
  font-size: 1.5em;
  text-align: center; 
  vertical-align: middle; 
  margin:0 auto;
}

p {
  font-size: 1.5em;
  text-align: center; 
  vertical-align: middle; 
  margin:0 auto;
}

table {
  font-size: 1.5em;
  text-align: left; 
  vertical-align: middle; 
  margin:0 auto;
}

.button {
  font-size: 22px;;
  text-align: center; 
}

.slidecontainer {
  width: 100%;
}

.slider {
  -webkit-appearance: none;
  width: 75%;
  height: 22px;
  background: #d3d3d3;
  outline: none;
  opacity: 0.7;
  -webkit-transition: .2s;
  transition: opacity .2s;
}

.slider:hover {
  opacity: 1;
}

.slider::-webkit-slider-thumb {
  -webkit-appearance: none;
  appearance: none;
  width: 18px;
  height: 18px;
  background: #4CAF50;
  cursor: pointer;
}

.slider::-moz-range-thumb {
  width: 18px;
  height: 18px;
  background: #4CAF50;
  cursor: pointer;
}

</style>

<title>Satfinder</title>
<hr>
<h1>Satfinder</h1>
<hr>

</head>

<body style="font-family: verdana,sans-serif" BGCOLOR="#819FF7">

  <table>
    <tr><td style="text-align:right;">Level:</td><td><meter id="led_level" value="0" min="0" max="100"></meter></td></tr>
  </table>
  <hr>

  <table>
    <tr>
      <td style="text-align:right;">Azimut:</td><td style="color:white;"><span id='azimut'></span> °</td>
      <td style="text-align:right;">Go Azimut:</td><td style="color:white;"><span id='s_azimut'></span> °</td>
    </tr>
  </table>

  <table>
    <tr>
      <td style="text-align:right;">Elevation:</td><td style="color:white;"><span id='elevation'></span> °</td>
      <td style="text-align:right;">Go Elevation:</td><td style="color:white;"><span id='s_elevation'></span> °</td>
    </tr>
  </table>

  <hr>

  <table>
    <tr><td style="text-align:right;">Rotor:</td><td style="color:white;"><span id='rotor'></span> °</td></tr>
  </table>
    
  <p>-70<input type="range" min="-70" max="70" step="1" value="0" class="slider" id="myRotorRange">+70</p>
    
  <p>
    <input type="button" class="button" value="-Step" onclick="button_clicked('rotor_down_step')">
    <input type="button" class="button" value="Down" onclick="button_clicked('rotor_down')">
    <input type="button" class="button" value="Up" onclick="button_clicked('rotor_up')">
    <input type="button" class="button" value="Step+" onclick="button_clicked('rotor_up_step')">
  </p>

  <hr>
    
  <table>
    <tr><td style="text-align:right;">Delta Azimut:</td><td style="color:white;"><span id='d_azimut'></span> °</td></tr>
  </table>
    
  <p>-50<input type="range" min="-50" max="50" step="1" value="0" class="slider" id="myAzRange">+50</p>
    
  <p>
    <input type="button" class="button" value="Down" onclick="button_clicked('az_down')">
    <input type="button" class="button" value="Up" onclick="button_clicked('az_up')">
  </p>

  <hr>
  
  <table>
    <tr><td style="text-align:right;">Delta Elevation:</td><td style="color:white;"><span id='d_elevation'></span> °</td></tr>
  </table>
    
  <p>-8<input type="range" min="-8" max="8" step="0.1" value="0" class="slider" id="myElRange">+8</p>  

  <p>
    <input type="button" class="button" value="Down" onclick="button_clicked('el_down')"> 
    <input type="button" class="button" value="Up" onclick="button_clicked('el_up')">
  </p> 

  <hr>
  
  <table>
    <tr><td style="text-align:right;">Auto:</td><td style="color:white;"><span id='state'></span></td></tr>
  </table>
 
  <p>
  <input type="button" class="button" value=" On " onclick="button_clicked('on')"> 
  <input type="button" class="button" value="Off" onclick="button_clicked('off')">
  <input type="button" class="button" value="R-Off" onclick="button_clicked('r_off')">
  </p>
  <hr>
  
  <script>
 
    requestData(); // get intial data straight away 

    var slider1 = document.getElementById("myAzRange");
    var output1 = document.getElementById("d_azimut");

    var slider2 = document.getElementById("myElRange");
    var output2 = document.getElementById("d_elevation");

    var slider3 = document.getElementById("myRotorRange");
    var output3 = document.getElementById("rotor");

    
    slider1.oninput = function() {
      output1.innerHTML = (this.value *1).toFixed(1);
      var xhr = new XMLHttpRequest();
      xhr.open('GET', 'slider1' + '?level=' + this.value, true);
      xhr.send();
    }

    slider2.oninput = function() {
      output2.innerHTML = (this.value *1).toFixed(1);
      var xhr = new XMLHttpRequest();
      xhr.open('GET', 'slider2' + '?level=' + this.value, true);
      xhr.send();
    }

    slider3.oninput = function() {
      output3.innerHTML = (this.value *1).toFixed(1);
      var xhr = new XMLHttpRequest();
      xhr.open('GET', 'slider3' + '?level=' + this.value, true);
      xhr.send();
    }



    
    function button_clicked(key) { 
      var xhr = new XMLHttpRequest();
      
      xhr.onreadystatechange = function() {
        if (this.readyState == 4 && this.status == 200) {
          requestData();       
        } 
      }     
      
      xhr.open('GET', key, true);
      xhr.send();      
    }
  
    // request data updates every 1000 milliseconds
    setInterval(requestData, 1000);
    
    function requestData() {

      var xhr = new XMLHttpRequest();
      
      xhr.onreadystatechange = function() {
        if (this.readyState == 4 && this.status == 200) {

          if (this.responseText) { // if the returned data is not null, update the values

            var data = JSON.parse(this.responseText);

            document.getElementById("led_level").value = (data.led_level *1).toFixed(1);
            document.getElementById("state").innerText = data.state;
            
            document.getElementById("azimut").innerText = (data.azimut *1).toFixed(1);
            document.getElementById("elevation").innerText = (data.elevation *1).toFixed(1);

            document.getElementById("s_azimut").innerText = (data.s_azimut *1).toFixed(1);
            document.getElementById("s_elevation").innerText = (data.s_elevation *1).toFixed(1);
            
            output1.innerHTML = (data.d_azimut*1).toFixed(1);
            slider1.value = data.d_azimut;
            
            output2.innerHTML = (data.d_elevation*1).toFixed(1);
            slider2.value = data.d_elevation;

            output3.innerHTML = (data.rotor*1).toFixed(1);
            slider3.value = data.rotor;
            
          } 
        } 
      }
      xhr.open('GET', 'get_data', true);
      xhr.send();
    }
     
  </script>

</body>

</html>

)=====";
