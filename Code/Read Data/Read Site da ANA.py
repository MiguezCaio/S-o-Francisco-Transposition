import requests
from bs4 import BeautifulSoup
import time
import os

html = """
<select class="form-control input-m-sm" id="dropDownListReservatorios" name="dropDownListReservatorios"><option value="">Selecione</option>
<option selected="selected" value="12003">ACARAPE DO MEIO                                   (CE)</option>
<option value="12004">ACARAÚ MIRIM                                      (CE)</option>
<option value="12006">ADAUTO BEZERRA                                    (CE)</option>
<option value="12019">AMANARY                                           (CE)</option>
<option value="12023">ANGICOS                                           (CE)</option>
<option value="12027">ARACOIABA                                         (CE)</option>
<option value="12030">ARARAS                                            (CE)</option>
<option value="12033">ARNEIROZ II                                       (CE)</option>
<option value="12034">ARREBITA                                          (CE)</option>
<option value="12036">ATALHO                                            (CE)</option>
<option value="12037">AYRES DE SOUZA                                    (CE)</option>
<option value="12039">BANABUIÚ                                          (CE)</option>
<option value="12043">BARRA VELHA                                       (CE)</option>
<option value="12523">BARRAGEM DO BATALHÃO                              (CE)</option>
<option value="12048">BATENTE                                           (CE)</option>
<option value="12052">BENGUÊ                                            (CE)</option>
<option value="12063">BONITO                                            (CE)</option>
<option value="12073">BROCO                                             (CE)</option>
<option value="12077">CACHOEIRA                                         (CE)</option>
<option value="12524">CALDEIRÕES                                        (CE)</option>
<option value="12096">CANAFÍSTULA                                       (CE)</option>
<option value="12098">CANOAS                                            (CE)</option>
<option value="12099">CAPITÃO MOR                                       (CE)</option>
<option value="12105">CARÃO                                             (CE)</option>
<option value="12107">CARMINA                                           (CE)</option>
<option value="12109">CARNAUBAL                                         (CE)</option>
<option value="12112">CASTANHÃO                                         (CE)</option>
<option value="12113">CASTRO                                            (CE)</option>
<option value="12115">CATUCINZENTA                                      (CE)</option>
<option value="12116">CAUHIPE                                           (CE)</option>
<option value="12117">CAXITORÉ                                          (CE)</option>
<option value="12118">CEDRO                                             (CE)</option>
<option value="12126">CIPOADA                                           (CE)</option>
<option value="12525">COCÓ                                              (CE)</option>
<option value="12132">COLINA                                            (CE)</option>
<option value="12142">CUPIM                                             (CE)</option>
<option value="12148">CURRAL VELHO                                      (CE)</option>
<option value="12151">DESTERRO                                          (CE)</option>
<option value="12152">DIAMANTE                                          (CE)</option>
<option value="12526">DIAMANTINO II                                     (CE)</option>
<option value="12153">DO CORONEL                                        (CE)</option>
<option value="12159">EDSON QUEIROZ                                     (CE)</option>
<option value="12160">EMA                                               (CE)</option>
<option value="12527">ESCURIDÃO                                         (CE)</option>
<option value="12528">FACUNDO                                           (CE)</option>
<option value="12177">FAÉ                                               (CE)</option>
<option value="12178">FARIAS DE SOUSA                                   (CE)</option>
<option value="12181">FAVELAS                                           (CE)</option>
<option value="12529">FIGUEIREDO                                        (CE)</option>
<option value="12184">FLOR DO CAMPO                                     (CE)</option>
<option value="12186">FOGAREIRO                                         (CE)</option>
<option value="12187">FORQUILHA                                         (CE)</option>
<option value="12188">FORQUILHA II                                      (CE)</option>
<option value="12190">FRIOS                                             (CE)</option>
<option value="12530">GAMELEIRA                                         (CE)</option>
<option value="12194">GANGORRA                                          (CE)</option>
<option value="12195">GAVIÃO                                            (CE)</option>
<option value="12197">GENERAL SAMPAIO                                   (CE)</option>
<option value="12198">GERARDO ATIMBONE                                  (CE)</option>
<option value="12531">GERMINAL                                          (CE)</option>
<option value="12202">GOMES                                             (CE)</option>
<option value="12497">Itapajé                                           (CE)</option>
<option value="12217">ITAPEBUSSU                                        (CE)</option>
<option value="12218">ITAÚNA                                            (CE)</option>
<option value="12219">JABURU I                                          (CE)</option>
<option value="12220">JABURU II                                         (CE)</option>
<option value="12225">JATOBÁ                                            (CE)</option>
<option value="12532">JATOBÁ II                                         (CE)</option>
<option value="12230">JENIPAPEIRO                                       (CE)</option>
<option value="12232">JENIPAPEIRO II                                    (CE)</option>
<option value="12533">JENIPAPO                                          (CE)</option>
<option value="12235">JERIMUM                                           (CE)</option>
<option value="12534">JOÃO LUÍS                                         (CE)</option>
<option value="12240">JOAQUIM TÁVORA                                    (CE)</option>
<option value="12244">JUNCO                                             (CE)</option>
<option value="12254">LIMA CAMPOS                                       (CE)</option>
<option value="12259">MACACOS                                           (CE)</option>
<option value="12260">MADEIRO                                           (CE)</option>
<option value="12264">MALCOZINHADO                                      (CE)</option>
<option value="12267">MAMOEIRO                                          (CE)</option>
<option value="12268">MANOEL BALBINO                                    (CE)</option>
<option value="12535">MARANGUAPINHO                                     (CE)</option>
<option value="12274">MARTINÓPOLE                                       (CE)</option>
<option value="12280">MISSI                                             (CE)</option>
<option value="12281">MONSENHOR TABOSA                                  (CE)</option>
<option value="12536">MONTE BELO                                        (CE)</option>
<option value="12287">MUNDAÚ                                            (CE)</option>
<option value="12289">MUQUÉM                                            (CE)</option>
<option value="12293">NOVA FLORESTA                                     (CE)</option>
<option value="12297">OLHO D'ÁGUA                                       (CE)</option>
<option value="12299">ORÓS                                              (CE)</option>
<option value="12301">PACAJUS                                           (CE)</option>
<option value="12302">PACOTI                                            (CE)</option>
<option value="12308">PARAMBU                                           (CE)</option>
<option value="12313">PATOS                                             (CE)</option>
<option value="12314">PATU                                              (CE)</option>
<option value="12318">PAU PRETO                                         (CE)</option>
<option value="12323">PEDRAS BRANCAS                                    (CE)</option>
<option value="12324">PENEDO                                            (CE)</option>
<option value="12325">PENTECOSTE                                        (CE)</option>
<option value="12326">PESQUEIRO                                         (CE)</option>
<option value="12334">PIRABIBU                                          (CE)</option>
<option value="12341">POÇO DA PEDRA                                     (CE)</option>
<option value="12343">POÇO DO BARRO                                     (CE)</option>
<option value="12348">POÇO VERDE                                        (CE)</option>
<option value="12352">POMPEU SOBRINHO                                   (CE)</option>
<option value="12355">POTIRETAMA                                        (CE)</option>
<option value="12358">PRAZERES                                          (CE)</option>
<option value="12359">PREMUOCA                                          (CE)</option>
<option value="12360">QUANDÚ                                            (CE)</option>
<option value="12363">QUINCOÉ                                           (CE)</option>
<option value="12364">QUIXABINHA                                        (CE)</option>
<option value="12365">QUIXERAMOBIM                                      (CE)</option>
<option value="12367">REALEJO                                           (CE)</option>
<option value="12369">RIACHÃO                                           (CE)</option>
<option value="12371">RIACHO DA SERRA                                   (CE)</option>
<option value="12375">RIACHO DO SANGUE                                  (CE)</option>
<option value="12380">RIVALDO DE CARVALHO                               (CE)</option>
<option value="12384">ROSÁRIO                                           (CE)</option>
<option value="12389">SALÃO                                             (CE)</option>
<option value="12397">SANTA MARIA                                       (CE)</option>
<option value="12398">SANTA MARIA DE ARACATIAÇU                         (CE)</option>
<option value="12401">SANTO ANTÔNIO                                     (CE)</option>
<option value="12403">SANTO ANTÔNIO DE ARACATIAÇU                       (CE)</option>
<option value="12404">SANTO ANTÔNIO DE RUSSAS                           (CE)</option>
<option value="12405">SÃO DOMINGOS                                      (CE)</option>
<option value="12407">SÃO DOMINGOS II                                   (CE)</option>
<option value="12412">SÃO JOSÉ I                                        (CE)</option>
<option value="12415">SÃO JOSÉ II                                       (CE)</option>
<option value="12418">SÃO JOSÉ III                                      (CE)</option>
<option value="12421">SÃO MATEUS                                        (CE)</option>
<option value="12423">SÃO PEDRO TIMBAÚBA                                (CE)</option>
<option value="12426">SÃO VICENTE                                       (CE)</option>
<option value="12427">SERAFIM DIAS                                      (CE)</option>
<option value="12440">SITIOS NOVOS                                      (CE)</option>
<option value="12441">SOBRAL                                            (CE)</option>
<option value="12445">SOUZA                                             (CE)</option>
<option value="12446">SUCESSO                                           (CE)</option>
<option value="12453">TAQUARA                                           (CE)</option>
<option value="12454">TATAJUBA                                          (CE)</option>
<option value="12457">TEJUÇUOCA                                         (CE)</option>
<option value="12459">THOMÁS OSTERNE                                    (CE)</option>
<option value="12460">TIGRE                                             (CE)</option>
<option value="12461">TIJUQUINHA                                        (CE)</option>
<option value="12465">TRAPIÁ II                                         (CE)</option>
<option value="12466">TRAPIÁ III                                        (CE)</option>
<option value="12470">TRICI                                             (CE)</option>
<option value="12471">TRUSSU                                            (CE)</option>
<option value="12473">TUCUNDUBA                                         (CE)</option>
<option value="12474">UBALDINHO                                         (CE)</option>
<option value="12475">UMARI                                             (CE)</option>
<option value="12480">VALÉRIO                                           (CE)</option>
<option value="12482">VÁRZEA DA VOLTA                                   (CE)</option>
<option value="12483">VÁRZEA DO BOI                                     (CE)</option>
<option value="12489">VIEIRÃO                                           (CE)</option>
</select>
"""

# Parse the HTML
soup = BeautifulSoup(html, 'html.parser')

# Extract all option values using list comprehension
option_values = [option['value'] for option in soup.find_all('option') if option.get('value')]

print(option_values)

estado=7
start_id=option_values[0]
data_inicial=f"02%2F05%2F2000"
data_final=f"02%2F05%2F2024"

link_padrao=f'https://www.ana.gov.br/sar0/Medicao?dropDownListEstados={estado}&dropDownListReservatorios={start_id}&dataInicial={data_inicial}&dataFinal={data_final}&button=Buscar'
diretorio = r'D:\Projetos\São francisco v2\Data\Reservatórios'
name_file=f"reservatorio_{start_id}_estado_{estado}.xls"
file_path = os.path.join(diretorio, name_file)
file_path
session = requests.Session()
response = session.get(link_padrao)

os.makedirs(diretorio, exist_ok=True)
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