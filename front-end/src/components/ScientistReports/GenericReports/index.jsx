import React ,{useEffect, useState} from 'react';
import Styles from './genericReports.module.css';
import axios from 'axios';

const GenericReports = () => {
    const [planets, setPlanets] = useState([]);
    const [stars, setStars] = useState([]);
    const [systems, setSystems] = useState([]);
    const [starsDist, setStarsDist] = useState([]);

    const [startRef, setStartRef] = useState("");
    const [minDist, setMinDist] = useState("");
    const [maxDist, setMaxDist] = useState("");


    
    useEffect(()=>{
        const dummyFunc = async ()=>{
            try {

                const response =  await axios.get('http://127.0.0.1:5000/relatorioCientista',);
                
                if (response.status === 200) {
                    const data = response.data;
                    setPlanets(data[0]);
                    setStars(data[1]);
                    setSystems(data[2]);
                }
            } catch (error) {
                alert(`Erro: ${error}`);
            }
        }
        dummyFunc();
    },[])

    const pegaEstrela = async ()=>{
        try {

            const response =  await axios.get(`http://127.0.0.1:5000/buscarDist?estrela=${startRef}&minDist=${minDist}&maxDist=${maxDist}`,);
            
            if (response.status === 200) {
                const data = response.data;
                setStarsDist(data)
            }
        } catch (error) {
            if(error.response?.status == 404){
                alert("Nenhuma Estrela encontrada no raio")
                return;
            }
            alert(`Erro: ${error}`);
        }
    }
    
    return (
        <>
            <div className={Styles.reportContainer}>
                <div className={Styles.report}>
                    <h3>Report Planeta</h3>
                    {
                        planets.map((p)=>(
                            <>
                                <h4>{p[0]}</h4>
                                <div className={Styles.agrupamento}>
                                    <p className={Styles.desc}>massa</p>
                                    <p className={Styles.val}>{p[1] ?? "não informado"}</p>
                                </div>
                                <div className={Styles.agrupamento}>
                                    <p className={Styles.desc}>raio</p>
                                    <p className={Styles.val}>{p[2] ?? "não informado"}</p>
                                </div>
                                <div className={Styles.agrupamento}>
                                    <p className={Styles.desc}>classificação</p>
                                    <p className={Styles.val}>{p[3] ?? "não informado"}</p>
                                </div>
                                <div className={Styles.agrupamento}>
                                    <p className={Styles.desc}>orbita</p>
                                    <p className={Styles.val}>{p[4] ?? "não informado"}</p>
                                </div>
                                <div className={Styles.agrupamento}>
                                    <p className={Styles.desc}>sistema</p>
                                    <p className={Styles.val}>{p[5] ?? "não informado"}</p>
                                </div>
                            </>
                        ))
                    }

                </div>
            </div>

            <div className={Styles.reportContainer}>
        <div className={Styles.report}>
        <h3>Report Estrelas</h3>
        {
            stars.map((s) => (
                <React.Fragment key={s[0]}>

                <h4>{s[0]}</h4> 
                <div className={Styles.agrupamento}>
                    <p className={Styles.desc}>Nome</p>
                    <p className={Styles.val}>{s[1] ?? "não informado"}</p>
                </div>
                <div className={Styles.agrupamento}>
                    <p className={Styles.desc}>Classificação</p>
                    <p className={Styles.val}>{s[2] ?? "não informado"}</p>
                </div>
                <div className={Styles.agrupamento}>
                    <p className={Styles.desc}>Massa</p>
                    <p className={Styles.val}>{s[3] ?? "não informado"}</p>
                </div>
                <div className={Styles.agrupamento}>
                    <p className={Styles.desc}>Coord X</p>
                    <p className={Styles.val}>{s[4] ?? "não informado"}</p>
                </div>
                <div className={Styles.agrupamento}>
                    <p className={Styles.desc}>Coord Y</p>
                    <p className={Styles.val}>{s[5] ?? "não informado"}</p>
                </div>
                <div className={Styles.agrupamento}>
                    <p className={Styles.desc}>Coord Z</p>
                    <p className={Styles.val}>{s[6] ?? "não informado"}</p>
                </div>
                <div className={Styles.agrupamento}>
                    <p className={Styles.desc}>Sistema</p>
                    <p className={Styles.val}>{s[7] ?? "não informado"}</p>
                </div>
                <div className={Styles.agrupamento}>
                    <p className={Styles.desc}>Estrela Orbitante</p>
                    <p className={Styles.val}>{s[8] ?? "não informado"}</p>
                </div>
                <div className={Styles.agrupamento}>
                    <p className={Styles.desc}>Dist Min Orbita</p>
                    <p className={Styles.val}>{s[9] ?? "não informado"}</p>
                </div>
                <div className={Styles.agrupamento}>
                    <p className={Styles.desc}>Dist Max Orbita</p>
                    <p className={Styles.val}>{s[10] ?? "não informado"}</p>
                </div>
                <div className={Styles.agrupamento}>
                    <p className={Styles.desc}>Período Orbita</p>
                    <p className={Styles.val}>{s[11] ?? "não informado"}</p>
                </div>
                </React.Fragment>
            ))}
            </div>
        </div>
        
        <div className={Styles.conjunto}>
            <div className={Styles.reportContainer}>
                <div className={Styles.report}>
                    <h3>Report Sistemas</h3>
                    {systems.map((sys) => (
                        <React.Fragment key={sys[0]}>
                        <div className={Styles.agrupamento}>
                            <p className={Styles.desc}>Estrela</p>
                            <p className={Styles.val}>{sys[0] ?? "não informado"}</p>
                        </div>
                        <div className={Styles.agrupamento}>
                            <p className={Styles.desc}>Nome do Sistema</p>
                            <p className={Styles.val}>{sys[1] ?? "não informado"}</p>
                        </div>
                        </React.Fragment>
                    ))}
                </div>
            </div>
            <div className={Styles.reportContainer}>
                <div className={Styles.report}>
                    <h3>Buscar Por distância</h3>
                    {
                        starsDist.length > 0 ? (
                                starsDist.map((sys)=>(
                                    <React.Fragment key={sys[0]}>
                                        <h4>{sys[0] }</h4>
                           
                                        <div className={Styles.agrupamento}>
                                            <p className={Styles.desc}>Nome</p>
                                            <p className={Styles.val}>{sys[2] ?? "não informado"}</p>
                                        </div>
                                        <div className={Styles.agrupamento}>
                                            <p className={Styles.desc}>Distância</p>
                                            <p className={Styles.val}>{sys[1] ?? "não informado"}</p>
                                        </div>
                                        <div className={Styles.agrupamento}>
                                            <p className={Styles.desc}>Classificação</p>
                                            <p className={Styles.val}>{sys[3] ?? "não informado"}</p>
                                        </div>
                                        <div className={Styles.agrupamento}>
                                            <p className={Styles.desc}>massa</p>
                                            <p className={Styles.val}>{sys[4] ?? "não informado"}</p>
                                        </div>
                                        <div className={Styles.agrupamento}>
                                            <p className={Styles.desc}>coord X</p>
                                            <p className={Styles.val}>{sys[5] ?? "não informado"}</p>
                                        </div>
                                        <div className={Styles.agrupamento}>
                                            <p className={Styles.desc}>coord Y</p>
                                            <p className={Styles.val}>{sys[6] ?? "não informado"}</p>
                                        </div>
                                        <div className={Styles.agrupamento}>
                                            <p className={Styles.desc}>coord Z</p>
                                            <p className={Styles.val}>{sys[7] ?? "não informado"}</p>
                                        </div>
                                    </React.Fragment>

                                ))

                        ) : 
                        (
                            <>
                                <input type="text" value={startRef} placeholder='ID da Estrela Referência' onChange={(e) => setStartRef(e.target.value)} />
                                <input type="text" value={minDist} placeholder='Distância Mínima' onChange={(e) => setMinDist(e.target.value)} />
                                <input type="text" value={maxDist} placeholder='Distância Máxima' onChange={(e) => setMaxDist(e.target.value)} />
                                <button onClick={pegaEstrela}>Buscar</button>
                            </>
                        )
                    }

                    
                </div>
            </div>

        </div>
           
        </>
    );
};

export default GenericReports;
