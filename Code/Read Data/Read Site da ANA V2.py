import requests
from bs4 import BeautifulSoup
import time
import os

html = """<select class="form-control input-m-sm" id="dropDownListReservatorios" name="dropDownListReservatorios"><option value="">Selecione</option>
<option selected="selected" value="12028">ARAPIRACA                                         (AL)</option>
<option value="12092">CAMPO GRANDE                                      (AL)</option>
<option value="12104">CARAIBINHAS                                       (AL)</option>
<option value="12131">COLÉGIO                                           (AL)</option>
<option value="12138">CRAÍBAS DOS NUNES                                 (AL)</option>
<option value="12150">DELMIRO GOUVEIA (SINIMBU)                         (AL)</option>
<option value="12154">DOIS RIACHOS                                      (AL)</option>
<option value="12204">GRAVATÁ                                           (AL)</option>
<option value="12221">JACARÉ DOS HOMENS                                 (AL)</option>
<option value="12224">JARAMATAIA                                        (AL)</option>
<option value="12263">MAJOR IZIDORO                                     (AL)</option>
<option value="12269">MARAVILHA                                         (AL)</option>
<option value="12303">PAI MANÉ                                          (AL)</option>
<option value="12304">PALMEIRA DOS ÍNDIOS (CORURIPE)                    (AL)</option>
<option value="12309">PARICONHA                                         (AL)</option>
<option value="12342">POÇO DAS TRINCHEIRAS                              (AL)</option>
<option value="12353">PONCIANO                                          (AL)</option>
<option value="12368">RETIRO                                            (AL)</option>
<option value="12373">RIACHO DO BODE                                    (AL)</option>
<option value="12410">SÃO JOSÉ DA TAPERA                                (AL)</option>
<option value="12436">SERTÃO DE BAIXO                                   (AL)</option>
<option value="12467">TRAVESSIA                                         (AL)</option>
</select>
"""

# Parse the HTML
soup = BeautifulSoup(html, 'html.parser')

# Extract all option values using list comprehension
option_values = [option['value'] for option in soup.find_all('option') if option.get('value')]

print(option_values)

def download_xls(estado, start_id):
    data_inicial = "02%2F05%2F2000"
    data_final = "02%2F05%2F2024"

    link_padrao = f"https://www.ana.gov.br/sar0/Medicao?dropDownListEstados={estado}&dropDownListReservatorios={start_id}&dataInicial={data_inicial}&dataFinal={data_final}&button=Buscar"
    diretorio = r'D:\Projetos\São francisco v2\Data\Reservatórios'
    name_file = f"reservatorio_{start_id}_estado_{estado}.xls"
    file_path = os.path.join(diretorio, name_file)

    session = requests.Session()
    response = session.get(link_padrao)

    os.makedirs(diretorio, exist_ok=True)
    time.sleep(5)  # Wait for 5 seconds

    # Parse the HTML
    soup = BeautifulSoup(response.text, 'html.parser')

    # Find the export link
    export_link = soup.find('a', href='/sar0/Medicao/ExportarExcel')

    if export_link:
        # Get the export URL
        export_url = f"https://www.ana.gov.br{export_link['href']}"
        
        # Make a request to the export URL
        export_response = session.get(export_url)
        
        # Check if the request was successful
        if export_response.status_code == 200:
            # Save the response content (XLS file)
            with open(file_path, 'wb') as f:
                f.write(export_response.content)
            print(f"XLS file downloaded successfully to: {file_path}")
        else:
            print(f"Failed to download XLS file. Status code: {export_response.status_code}")
    else:
        print("Export link not found.")

# Example usage:
estado = 3
start_id = option_values[0]  # You need to define option_values
download_xls(estado, start_id)

##Now for all of Ceará

for id in option_values:
    download_xls(estado,id)