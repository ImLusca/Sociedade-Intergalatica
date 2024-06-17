import React, { useEffect, useState } from 'react';
import Styles from './genericReports.module.css';
import axios from 'axios';
import Cookies from "js-cookie";

const LeaderReports = () => {
    const [planets, setPlanets] = useState([]);
    const [species, setSpecies] = useState([]);
    const [nation, setNation] = useState([]);
    const [system, setSystem] = useState([]);

    const faction = Cookies.get("userFaction");

    useEffect(() => {
        const planeta = async () => {
            try {
                const response = await axios.get(`http://127.0.0.1:5000/relatoriosLiderPlaneta?faccao=${faction}`,);
                if (response.status === 200) {
                    const data = response.data;
                    setPlanets(data);
                }
            } catch (error) {
                console.log(error)
            }
        }
        const especie = async () => {
            try {
                const response = await axios.get(`http://127.0.0.1:5000/relatoriosLiderEspecie?faccao=${faction}`,);
                if (response.status === 200) {
                    const data = response.data;
                    setSpecies(data);
                }
            } catch (error) {
                console.log(error)
            }
        }
        const system = async () => {
            try {
                const response = await axios.get(`http://127.0.0.1:5000/relatoriosLiderSistema?faccao=${faction}`,);
                if (response.status === 200) {
                    const data = response.data;
                    setSystem(data);
                }
            } catch (error) {
                console.log(error)

            }
        }
        const nation = async () => {
            try {
                const response = await axios.get(`http://127.0.0.1:5000/relatoriosLidernacao?faccao=${faction}`,);
                if (response.status === 200) {
                    const data = response.data;
                    setNation(data);
                }
            } catch (error) 
            {
                console.log(error)
            }
        }

        planeta();
        especie();
        system();
        nation();
    }, [])

    return (
        <>
            <div className={Styles.reportContainer}>
                <div className={Styles.report}>
                    <h3>Report Lider Planetas</h3>
                    {
                        planets.map((s) => (
                            <React.Fragment key={s[0]}>

                                <h4>{s[0]}</h4>
                                <div className={Styles.agrupamento}>
                                    <p className={Styles.desc}>Qtd. Especies</p>
                                    <p className={Styles.val}>{s[1] ?? "não informado"}</p>
                                </div>
                                <div className={Styles.agrupamento}>
                                    <p className={Styles.desc}>População</p>
                                    <p className={Styles.val}>{s[2] ?? "não informado"}</p>
                                </div>
                            </React.Fragment>
                        ))}
                </div>
            </div>

            <div className={Styles.reportContainer}>
                <div className={Styles.report}>
                    <h3>Report Lider Espécies</h3>
                    {species.map((sys) => (
                        <React.Fragment key={sys[0]}>
                            <h4>{sys[0]}</h4>
                            <div className={Styles.agrupamento}>
                                <p className={Styles.desc}>N. Comunidades</p>
                                <p className={Styles.val}>{sys[1] ?? "não informado"}</p>
                            </div>
                            <div className={Styles.agrupamento}>
                                <p className={Styles.desc}>N. Habitantes</p>
                                <p className={Styles.val}>{sys[2] ?? "não informado"}</p>
                            </div>
                        </React.Fragment>
                    ))}
                </div>
            </div>

            <div className={Styles.reportContainer}>
                <div className={Styles.report}>
                    <h3>Report Lider Espécies</h3>
                    {species.map((sys) => (
                        <React.Fragment key={sys[0]}>
                            <h4>{sys[0]}</h4>
                            <div className={Styles.agrupamento}>
                                <p className={Styles.desc}>N. Comunidades</p>
                                <p className={Styles.val}>{sys[1] ?? "não informado"}</p>
                            </div>
                            <div className={Styles.agrupamento}>
                                <p className={Styles.desc}>N. Habitantes</p>
                                <p className={Styles.val}>{sys[2] ?? "não informado"}</p>
                            </div>
                        </React.Fragment>
                    ))}
                </div>
            </div>

            <div className={Styles.reportContainer}>
                <div className={Styles.report}>
                    <h3>Report Lider Nações</h3>
                    {system.map((sys) => (
                        <React.Fragment key={sys[0]}>
                            <h4>{sys[0]}</h4>
                            <div className={Styles.agrupamento}>
                                <p className={Styles.desc}>N. Comunidades</p>
                                <p className={Styles.val}>{sys[1] ?? "não informado"}</p>
                            </div>
                            <div className={Styles.agrupamento}>
                                <p className={Styles.desc}>N. Habitantes</p>
                                <p className={Styles.val}>{sys[2] ?? "não informado"}</p>
                            </div>
                        </React.Fragment>
                    ))}
                </div>
            </div>


        </>
    );
};

export default LeaderReports;
