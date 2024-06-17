import React, { useEffect, useState } from 'react';
import Styles from './genericReports.module.css';
import axios from 'axios';
import Cookies from "js-cookie";

const OfficerReport = () => {
    const [planets, setPlanets] = useState([]);
    const [species, setSpecies] = useState([]);
    const [habitantes, setHabitantes] = useState([]);
    const [system, setSystem] = useState([]);

    const cpi = Cookies.get("userFaction");

    useEffect(() => {
        const planeta = async () => {
            try {
                const response = await axios.get(`http://127.0.0.1:5000/relatoriosoficiaisplaneta?lider=${cpi}`,);
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
                const response = await axios.get(`http://127.0.0.1:5000/relatoriosoficiaisEspecies?lider=${cpi}`,);
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
                const response = await axios.get(`http://127.0.0.1:5000/relatoriosoficiaissistema?lider=${cpi}`,);
                if (response.status === 200) {
                    const data = response.data;
                    setSystem(data);
                }
            } catch (error) {
                console.log(error)

            }
        }
        const habitation = async () => {
            try {
                const response = await axios.get(`http://127.0.0.1:5000/relatoriosoficiaishabitantes?lider=${cpi}`,);
                if (response.status === 200) {
                    const data = response.data;
                    setHabitantes(data);
                }
            } catch (error) 
            {
                console.log(error)
            }
        }

        planeta();
        especie();
        system();
        habitation();
    }, [])

    return (
        <>
            <div className={Styles.reportContainer}>
                <div className={Styles.report}>
                    <h3>Report Oficial Planetas</h3>
                    {
                        planets.map((s) => (
                            <React.Fragment key={s[0]}>

                                <h4>{s[0]}</h4>
                                <div className={Styles.agrupamento}>
                                    <p className={Styles.desc}>Data</p>
                                    <p className={Styles.val}>{s[1] ?? "não informado"}</p>
                                </div>
                                <div className={Styles.agrupamento}>
                                    <p className={Styles.desc}>n habitantes</p>
                                    <p className={Styles.val}>{s[2] ?? "não informado"}</p>
                                </div>
                            </React.Fragment>
                        ))}
                </div>
            </div>

            <div className={Styles.reportContainer}>
                <div className={Styles.report}>
                    <h3>Report Oficial Espécies</h3>
                    {species.map((sys) => (
                        <React.Fragment key={sys[0]}>
                            <h4>{sys[0]}</h4>
                            <div className={Styles.agrupamento}>
                                <p className={Styles.desc}>Data</p>
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
                    <h3>Report Ofiial Sistemas</h3>
                    {system.map((sys) => (
                        <React.Fragment key={sys[0]}>
                            <h4>{sys[0]}</h4>
                            <div className={Styles.agrupamento}>
                                <p className={Styles.desc}>Data</p>
                                <p className={Styles.val}>{sys[1] ?? "não informado"}</p>
                            </div>
                            <div className={Styles.agrupamento}>
                                <p className={Styles.desc}>Num habitantes</p>
                                <p className={Styles.val}>{sys[2] ?? "não informado"}</p>
                            </div>
                        </React.Fragment>
                    ))}
                </div>
            </div>

            <div className={Styles.reportContainer}>
                <div className={Styles.report}>
                    <h3>Report Oficial Facções</h3>
                    {habitantes.map((sys) => (
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

export default OfficerReport;
